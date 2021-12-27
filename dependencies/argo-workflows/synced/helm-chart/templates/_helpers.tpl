{{/*
Return the proper server image name
*/}}
{{- define "argo-workflows.server.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.server.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper controller image name
*/}}
{{- define "argo-workflows.controller.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.controller.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper executor image name
*/}}
{{- define "argo-workflows.executor.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.executor.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper service name for Argo Workflows server
*/}}
{{- define "argo-workflows.server.fullname" -}}
  {{- printf "%s-server" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Return the proper service name for Argo Workflows controller
*/}}
{{- define "argo-workflows.controller.fullname" -}}
  {{- printf "%s-controller" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Create a default fully qualified postgresql name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "argo-workflows.postgresql.fullname" -}}
{{- $name := default "postgresql" .Values.postgresql.nameOverride -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "postgresql" "chartValues" .Values.postgresql "context" $) -}}
{{- end -}}

{{/*
Create a default fully qualified mysql name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "argo-workflows.mysql.fullname" -}}
{{- $name := default "mysql" .Values.mysql.nameOverride -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "mysql" "chartValues" .Values.mysql "context" $) -}}
{{- end -}}

{{/*
Create the name of the server service account to use
*/}}
{{- define "argo-workflows.server.serviceAccountName" -}}
{{- if .Values.server.serviceAccount.create -}}
    {{ default (printf "%s-server" (include "common.names.fullname" .)) .Values.server.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.server.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the controller service account to use
*/}}
{{- define "argo-workflows.controller.serviceAccountName" -}}
{{- if .Values.controller.serviceAccount.create -}}
    {{ default (printf "%s-controller" (include "common.names.fullname" .)) .Values.controller.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.controller.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the workflows service account to use
*/}}
{{- define "argo-workflows.workflows.serviceAccountName" -}}
{{- if .Values.workflows.serviceAccount.create -}}
    {{ default (printf "%s-workflows" (include "common.names.fullname" .)) .Values.workflows.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.workflows.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "argo-workflows.imagePullSecrets" -}}
{{- include "common.images.pullSecrets" (dict "images" (list .Values.server.image .Values.controller.image) "global" .Values.global) -}}
{{- end -}}

{{/*
Return the proper configmap for the controller
*/}}
{{- define "argo-workflows.controller.configMapName" -}}
{{- if .Values.controller.existingConfigMap }}
{{- .Values.controller.existingConfigMap -}}
{{- else -}}
{{- include "argo-workflows.controller.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*
Return true if persistence is enabled
*/}}
{{- define "argo-workflows.controller.persistence.enabled" -}}
{{- if or .Values.postgresql.enabled .Values.mysql.enabled .Values.externalDatabase.enabled -}}
{{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper database username
*/}}
{{- define "argo-workflows.controller.database.username" -}}
{{- if .Values.postgresql.enabled -}}
{{- .Values.postgresql.postgresqlUsername -}}
{{- end -}}
{{- if .Values.mysql.enabled -}}
{{- .Values.mysql.auth.username -}}
{{- end -}}
{{- if .Values.externalDatabase.enabled -}}
{{- .Values.externalDatabase.username -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper database username secret name
*/}}
{{- define "argo-workflows.controller.database.username.secret" -}}
{{- printf "%s-%s" (include "argo-workflows.controller.fullname" .) "database" -}}
{{- end -}}

{{/*
Return the proper database password secret
*/}}
{{- define "argo-workflows.controller.database.password.secret" -}}
{{- if .Values.postgresql.enabled -}}
{{- include "argo-workflows.postgresql.fullname" . -}}
{{- end -}}
{{- if .Values.mysql.enabled -}}
{{- include "argo-workflows.mysql.fullname" . -}}
{{- end -}}
{{- if .Values.externalDatabase.enabled -}}
{{- if .Values.externalDatabase.existingSecret -}}
{{- tpl .Values.externalDatabase.existingSecret . -}}
{{- else -}}
{{- include "argo-workflows.controller.database.username.secret" . -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper database password secret key
*/}}
{{- define "argo-workflows.controller.database.password.secret.key" -}}
{{- if .Values.postgresql.enabled -}}
{{- printf "%s" "postgresql-password" -}}
{{- end -}}
{{- if .Values.mysql.enabled -}}
{{- printf "%s" "mysql-password" -}}
{{- end -}}
{{- if .Values.externalDatabase.enabled -}}
{{- printf "%s" "database-password" -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper database host
The validate values function checks that both types are not set at the same time
*/}}
{{- define "argo-workflows.controller.database.host" -}}
{{- if .Values.postgresql.enabled -}}
{{- include "argo-workflows.postgresql.fullname" . -}}
{{- end -}}
{{- if .Values.mysql.enabled -}}
{{- include "argo-workflows.mysql.fullname" . -}}
{{- end -}}
{{- if .Values.externalDatabase.enabled -}}
{{- .Values.externalDatabase.host -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper database
*/}}
{{- define "argo-workflows.controller.database" -}}
{{- if .Values.postgresql.enabled -}}
{{- .Values.postgresql.postgresqlDatabase -}}
{{- end -}}
{{- if .Values.mysql.enabled -}}
{{- .Values.mysql.auth.database -}}
{{- end -}}
{{- if .Values.externalDatabase.enabled -}}
{{- .Values.externalDatabase.database -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper database port
*/}}
{{- define "argo-workflows.controller.database.port" -}}
{{- if .Values.postgresql.enabled -}}
{{- .Values.postgresql.service.port -}}
{{- end -}}
{{- if .Values.mysql.enabled -}}
{{- .Values.mysql.service.port -}}
{{- end -}}
{{- if .Values.externalDatabase.enabled -}}
{{- .Values.externalDatabase.port -}}
{{- end -}}
{{- end -}}

{{/*
Validate database configuration
*/}}
{{- define "argo-workflows.validate.database.config" -}}
{{- if or (and .Values.postgresql.enabled .Values.mysql.enabled) (and .Values.externalDatabase.enabled .Values.mysql.enabled) (and .Values.postgresql.enabled .Values.externalDatabase.enabled) -}}
{{- printf "Validation error: more than one type of database specified, you should either configure postgresql, mysql or an external database" -}}
{{- end -}}
{{- if and .Values.externalDatabase.enabled (not .Values.externalDatabase.database) -}}
{{- printf "Validation error: External database provided without the database parameter" -}}
{{- end -}}
{{- if and .Values.externalDatabase.enabled (not .Values.externalDatabase.type) -}}
{{- printf "Validation error: External database provided without the database type parameter" -}}
{{- end -}}
{{- end -}}

{{/*
Return true if cert-manager required annotations for TLS signed certificates are set in the Ingress annotations
Ref: https://cert-manager.io/docs/usage/ingress/#supported-annotations
*/}}
{{- define "argo-workflows.ingress.certManagerRequest" -}}
{{ if or (hasKey . "cert-manager.io/cluster-issuer") (hasKey . "cert-manager.io/issuer") }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "argo-workflows.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "argo-workflows.validate.database.config" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}
