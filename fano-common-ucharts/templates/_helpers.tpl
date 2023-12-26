{{/*
Expand the name of the chart.
*/}}
{{- define "fanolabs.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fanolabs.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "fanolabs.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "fanolabs.labels" -}}
helm.sh/chart: {{ include "fanolabs.chart" . }}
{{ include "fanolabs.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "fanolabs.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fanolabs.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
service: {{ include "fanolabs.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "fanolabs.serviceAccountName" -}}
{{- $serviceAccount := .Values.serviceAccount.name -}}
{{- if .global }}
{{- if .global.serviceAccount }}
    {{- $serviceAccount = .global.serviceAccount -}}
{{- end -}}
{{- end -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "fanolabs.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default $serviceAccount .Values.serviceAccount.name }}
{{- end }}
{{- end }}
