{{/*
Return the proper Argo CD image name
*/}}
{{- define "argocd.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Dex image name
*/}}
{{- define "argocd.dex.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.dex.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "argocd.volumePermissions.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.volumePermissions.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "argocd.imagePullSecrets" -}}
{{- include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.dex.image .Values.volumePermissions.image) "global" .Values.global) -}}
{{- end -}}

{{/*
Return the proper service name for Argo CD controller
*/}}
{{- define "argocd.application-controller" -}}
  {{- printf "%s-app-controller" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Return the proper service name for Argo CD server
*/}}
{{- define "argocd.server" -}}
  {{- printf "%s-server" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Return the proper service name for Argo CD repo server
*/}}
{{- define "argocd.repo-server" -}}
  {{- printf "%s-repo-server" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Return the proper service name for Dex
*/}}
{{- define "argocd.dex" -}}
  {{- printf "%s-dex" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Create a default fully qualified redis name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "argocd.redis.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "redis" "chartValues" .Values.redis "context" $) -}}
{{- end -}}

{{/*
Create a default name for known hosts configmap.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "argocd.custom-styles.fullname" -}}
{{- if .Values.config.existingStylesConfigmap -}}
{{- .Values.config.existingStylesConfigmap -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name "custom-styles" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for the Argo CD server
*/}}
{{- define "argocd.server.serviceAccountName" -}}
{{- if .Values.server.serviceAccount.create -}}
    {{ default (printf "%s-argocd-server" (include "common.names.fullname" .)) .Values.server.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.server.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for the Argo CD application controller
*/}}
{{- define "argocd.application-controller.serviceAccountName" -}}
{{- if .Values.controller.serviceAccount.create -}}
    {{ default (printf "%s-argocd-app-controller" (include "common.names.fullname" .)) .Values.controller.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.controller.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for the Argo CD repo server
*/}}
{{- define "argocd.repo-server.serviceAccountName" -}}
{{- if .Values.repoServer.serviceAccount.create -}}
    {{ default (printf "%s-argocd-repo-server" (include "common.names.fullname" .)) .Values.repoServer.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.repoServer.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for Dex
*/}}
{{- define "argocd.dex.serviceAccountName" -}}
{{- if .Values.dex.serviceAccount.create -}}
    {{ default (printf "%s-dex" (include "common.names.fullname" .)) .Values.dex.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
    {{ default "default" .Values.dex.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}

{{/*
Return the Redis&trade; secret name
*/}}
{{- define "argocd.redis.secretName" -}}
{{- if .Values.redis.enabled }}
    {{- if .Values.redis.auth.existingSecret }}
        {{- printf "%s" .Values.redis.auth.existingSecret -}}
    {{- else -}}
        {{- printf "%s" (include "argocd.redis.fullname" .) }}
    {{- end -}}
{{- else if .Values.externalRedis.existingSecret }}
    {{- printf "%s" .Values.externalRedis.existingSecret -}}
{{- else -}}
    {{- printf "%s-redis" (include "argocd.redis.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis&trade; secret key
*/}}
{{- define "argocd.redis.secretPasswordKey" -}}
{{- if and .Values.redis.enabled .Values.redis.auth.existingSecret }}
    {{- .Values.redis.auth.existingSecretPasswordKey | printf "%s" }}
{{- else if and (not .Values.redis.enabled) .Values.externalRedis.existingSecret }}
    {{- .Values.externalRedis.existingSecretPasswordKey | printf "%s" }}
{{- else -}}
    {{- printf "redis-password" -}}
{{- end -}}
{{- end -}}

{{/*
Return whether Redis&trade; uses password authentication or not
*/}}
{{- define "argocd.redis.auth.enabled" -}}
{{- if or (and .Values.redis.enabled .Values.redis.auth.enabled) (and (not .Values.redis.enabled) (or .Values.externalRedis.password .Values.externalRedis.existingSecret)) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis&trade; hostname
*/}}
{{- define "argocd.redisHost" -}}
{{- if .Values.redis.enabled }}
    {{- printf "%s-master" (include "argocd.redis.fullname" .) -}}
{{- else -}}
    {{- required "If the redis dependency is disabled you need to add an external redis host" .Values.externalRedis.host -}}
{{- end -}}
{{- end -}}

{{/*
Return the Redis&trade; port
*/}}
{{- define "argocd.redisPort" -}}
{{- if .Values.redis.enabled }}
    {{- .Values.redis.service.port -}}
{{- else -}}
    {{- .Values.externalRedis.port -}}
{{- end -}}
{{- end -}}

{{/*
Validate Redis config
*/}}
{{- define "argocd.validateValues.redis" -}}
{{- if and .Values.redis.enabled .Values.redis.auth.existingSecret }}
    {{- if not .Values.redis.auth.existingSecretPasswordKey -}}
Argo CD: You need to provide existingSecretPasswordKey when an existingSecret is specified in redis dependency
    {{- end -}}
{{- else if and (not .Values.redis.enabled) .Values.externalRedis.existingSecret }}
    {{- if not .Values.externalRedis.existingSecretPasswordKey -}}
Argo CD: You need to provide existingSecretPasswordKey when an existingSecret is specified in redis
    {{- end }}
{{- end -}}
{{- end -}}

{{/*
Validate external Redis config
*/}}
{{- define "argocd.validateValues.externalRedis" -}}
{{- if not .Values.redis.enabled -}}
Argo CD: If the redis dependency is disabled you need to add an external redis port
{{- end -}}
{{- end -}}

{{/*
Validate Dex config
*/}}
{{- define "argocd.validateValues.dex.config" -}}
{{- if .Values.dex.enabled -}}
{{- if not .Values.server.url -}}
Argo CD: server.url must be set when enabling Dex for SSO. Please add `--set server.url=<your-argo-cd-url>` to the installation parameters.
{{- end -}}
{{- if not (index .Values "server" "config" "dex.config") -}}
Argo CD: server.config.dex\.config must be set when enabling Dex for SSO. Please add `--set server.config.dex\.config=<your-dex-configuration>` to the installation parameters.
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Validate cluster credentials
*/}}
{{- define "argocd.validateValues.clusterCredentials" -}}
{{- range .Values.config.clusterCredentials -}}
{{- if not .name -}}
Argo CD: A valid .name entry is required in all clusterCrendials objects!
{{- end -}}
{{- if not .server -}}
Argo CD: A valid .server entry is required in all clusterCrendials objects!
{{- end -}}
{{- if not .config -}}
Argo CD: A valid .config entry is required in all clusterCrendials objects!
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "argocd.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "argocd.validateValues.dex.config" .) -}}
{{- $messages := append $messages (include "argocd.validateValues.clusterCredentials" .) -}}
{{- $messages := append $messages (include "argocd.validateValues.externalRedis" .) -}}
{{- $messages := append $messages (include "argocd.validateValues.redis" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}
{{- end -}}
