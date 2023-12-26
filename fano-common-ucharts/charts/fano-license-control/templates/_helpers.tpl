{{/*
Expand the name of the chart.
*/}}
{{- define "speech.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "speech.fullname" -}}
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
{{- define "speech.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "speech.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.image) "global" .Values.global) }}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "speech.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "speech.labels" -}}
helm.sh/chart: {{ include "speech.chart" . }}
{{ include "speech.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "speech.selectorLabels" -}}
app.kubernetes.io/name: {{ include "speech.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "speech.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "speech.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
tls volume mount template
 */}}
{{- define "tls-volume-mount" -}}
{{- if .Values.global.tls.enabled }}
- mountPath: /ssl
  name: speech-tls
  readOnly: true
{{- end }}
{{- end }}

{{/*
tls volume template
 */}}
{{- define "tls-volume" -}}
{{- if .Values.global.tls.enabled }}
- name: speech-tls
  secret:
    secretName: {{ .Values.global.tls.secretName }}
{{- end }}
{{- end }}

{{/*
grpc healthcheck tls args template
 */}}
{{- define "grpc-healthcheck-tls-args" -}}
{{- if .Values.global.tls.enabled }}
- --tls
- --tls-ca-cert=/ssl/ca.crt
- --tls-client-cert=/ssl/tls.crt
- --tls-client-key=/ssl/tls.key
{{- end }}
{{- end }}

{{/*
grpc gateway tls arg template
 */}}
{{- define "grpc-gateway-tls-args" -}}
{{- if .Values.global.tls.enabled }}
- --grpc-ca-cert=/ssl/ca.crt
- --grpc-client-cert=/ssl/tls.crt
- --grpc-client-key=/ssl/tls.key
- --grpc-server-cert=/ssl/tls.crt
- --grpc-server-key=/ssl/tls.key
- --ca-cert=/ssl/ca.crt
- --server-cert=/ssl/tls.crt
- --server-key=/ssl/tls.key
{{- end }}
{{- end }}

{{/*
grpc client tls arg js template
 */}}
{{- define "grpc-client-args-js" -}}
{{- if .Values.global.tls.enabled }}
- --grpc-ca-cert=/ssl/ca.crt
- --grpc-client-cert=/ssl/tls.crt
- --grpc-client-key=/ssl/tls.key
- --grpc-uri=localhost:5000
{{- end }}
{{- end }}

{{/*
grpc server tls arg python template
 */}}
{{- define "grpc-server-args-py" -}}
{{- if .Values.global.tls.enabled }}
- --ca_cert=/ssl/ca.crt
- --server_cert=/ssl/tls.crt
- --server_key=/ssl/tls.key
{{- end }}
{{- end }}

{{/*
license arg template
 */}}
{{- define "license-arg" -}}
{{- if .Values.licenseControl.useExternal }}
- --license-service-uri={{ .Values.licenseControl.useExternal }}
{{- else }}
{{- if .Values.global.tls.enabled }}
- --license-service-uri=https://{{ .Release.Name }}-license-control-service.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.licenseControl.port }}
{{- else }}
- --license-service-uri=http://{{ .Release.Name }}-license-control-service.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.licenseControl.port }}
{{- end }}
{{- end }}
{{- end }}

{{/*
new license arg template
 */}}
{{- define "new-license-arg" -}}
{{- if .Values.global.licenseClient.tls.enabled }}
- --license-service-uri=https://{{ .Values.global.licenseClient.url }}:{{ .Values.global.licenseClient.port }}
{{- else }}
- --license-service-uri=http://{{ .Values.global.licenseClient.url }}:{{ .Values.global.licenseClient.port }}
{{- end }}
{{- end }}
