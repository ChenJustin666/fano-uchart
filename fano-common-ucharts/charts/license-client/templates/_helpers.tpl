{{/*
Expand the name of the chart.
*/}}
{{- define "license-client.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "license-client.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Return the proper image name
*/}}
{{- define "license-client.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "license-client.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.image) "global" .Values.global) }}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "license-client.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "license-client.labels" -}}
helm.sh/chart: {{ include "license-client.chart" . }}
{{ include "license-client.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "license-client.selectorLabels" -}}
app.kubernetes.io/name: {{ include "license-client.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
license db url template
 */}}
{{- define "license-client.db-url" -}}
{{- $typeMap := dict "mssql" "mssql" "mysql" "mysql" "oracle" "oracle" "postgres" "postgres" }}
{{- $host := printf "%s:%s" .Values.parameter.db.url (.Values.parameter.db.port | toString ) }}
{{- $database := printf "/%s" .Values.parameter.db.database }}
{{- $type := index $typeMap .Values.parameter.db.type }}
{{- print $type "://" $host $database }}
{{- end }}

{{/*
license smtp url template
 */}}
{{- define "license-client.smtp-url" -}}
{{- $url := printf "%s:%s" .Values.parameter.smtp.url (.Values.parameter.smtp.port | toString ) }}
{{- print "smtp://" "$(SMTP_USERNAME):$(SMTP_PASSWORD)@" $url }}
{{- end }}

{{/*
license redis url template
 */}}
{{- define "license-client.redis-url" -}}
{{- $url := printf "%s:%s" .Values.parameter.redis.url (.Values.parameter.redis.port | toString ) }}
{{- print "redis://" "" $url }}
{{- end }}

{{/*
wait for postgres dns init container template
 */}}
{{- define "license-client.wait-postgres-dns-init-container" -}}
- name: wait-postgres
  image: busybox:stable
  command: ['sh', '-c', 'until nslookup {{ .Values.parameter.db.url }}; do echo waiting for {{ .Values.parameter.db.url }}; sleep 2; done;']
{{- end }}

{{/*
tls volume mount template
 */}}
{{- define "license-client.tls-volume-mount" -}}
{{- if .Values.tls.enabled }}
- mountPath: /ssl
  name: test-tls
  readOnly: true
{{- end }}
{{- end }}

{{/*
tls volume template
 */}}
{{- define "license-client.tls-volume" -}}
{{- if .Values.tls.enabled }}
- name: test-tls
  secret:
    secretName: {{ .Values.tls.existingSecret }}
{{- end }}
{{- end }}

{{/*
db tls volume mount template
 */}}
{{- define "license-client.db.tls-volume-mount" -}}
{{- if .Values.parameter.db.tls.enabled }}
- mountPath: /db/ssl
  name: db-tls
  readOnly: true
{{- end }}
{{- end }}

{{/*
dbtls volume template
 */}}
{{- define "license-client.db.tls-volume" -}}
{{- if .Values.parameter.db.tls.enabled }}
- name: db-tls
  secret:
    secretName: {{ .Values.parameter.db.tls.existingSecret }}
{{- end }}
{{- end }}


