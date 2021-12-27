#!/bin/bash
set -e

printf "\n⌛ 🤚 🤌   Please wait while syncing vendir dependencies...\n"
vendir sync --locked

# clean previously rendered files
printf "\n🧹 🧽 ✨  Clearing previously auto-rendered templates...\n"
rm -rf ./deploy/generated-manifests

# Yay while loops!
while IFS= read -r -d '' app_directory ; do
  app_name="$(basename "$app_directory")"

  printf "\n🧹 🧽 ✨  Looping through $app_name...\n"

  if [ -d "./deploy/overlays/$app_name" ]; then
    mkdir -p "./deploy/generated-manifests/$app_name"
  fi

  # render Helm templates if Chart.yaml file is found
  SYNCED_DIR="./deploy/synced/$app_name"

  if [ -f "./deploy/synced/$app_name/Chart.yaml" ]; then
    printf "\n🚨 🛎  📢  Found Helm Chart for $app_name !! \n"
    tmp_helm_rendered=$(mktemp -u).yml

      if [ -f "./deploy/chart-values/$app_name/values.yaml" ]; then
        printf "\n🚨 🛎  📢  Found custom Helm chart values for $app_name !! \n"
        printf "\n🚨 🛎  📢  Rendering $app_name with custom values !! \n"
        # Render the templates WITH values included
        helm template "$app_name" "./deploy/synced/$app_name" \
          --values "./deploy/chart-values/$app_name/values.yaml" \
          > "$tmp_helm_rendered"
      else
        printf "\n🚨 🛎  📢  NO custom Helm chart values found for $app_name !! \n"
        printf "\n🚨 🛎  📢  Rendering $app_name with default Helm chart values !! \n"
        helm template "$app_name" "./deploy/synced/$app_name" > "$tmp_helm_rendered"
      fi

    SYNCED_DIR="$tmp_helm_rendered"

  fi

  if [ -d "./deploy/overlays/$app_name" ]; then
    printf "\n🛠  🧙 🪄   Magically generated --> $app_name/deploy.yaml \n\n"
    ytt --file "$SYNCED_DIR" --file "./deploy/overlays/$app_name" > "./deploy/generated-manifests/$app_name/deploy.yaml"
  fi

done < <(find ./deploy/synced/* -maxdepth 0 -type d -print0)
printf "\n ######################__ALL_DONE__###################### \n\n"


	# tmp_aws_creds_rendered=$(mktemp -u).conf && \
    # cat << EOF > "$$tmp_aws_creds_rendered" \
	# "HI MOM!" \
	# EOF \
	# && cat $$tmp_aws_creds_rendered
