{{/*
Return the PVC name
{{ include "fanocommon.claimName" ( dict "persistence" .Values.persistence "global" $) }}
*/}}
{{- define "fanocommon.claimName" -}}
{{- $existingClaim := .persistence.existingClaim -}}
{{- if .global }}
    {{- if .global.existingClaim }}
     {{- $existingClaim = .global.existingClaim -}}
    {{- end -}}
{{- end -}}
{{- printf "%s" $existingClaim -}}
{{- end -}}