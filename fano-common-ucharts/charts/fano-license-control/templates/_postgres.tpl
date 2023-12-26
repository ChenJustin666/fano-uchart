{{/*
wait for postgres dns init container template
{{ include "speech.wait-rdbms-dns-init-container" (dict "rdbmsRoot" .Values.path.to.the.rdbms "global" .Values.global) }}
 */}}
{{- define "speech.wait-rdbms-dns-init-container" -}}
{{- $host := "rdbms" -}}
{{- if .rdbmsRoot -}}
    {{- $host = .rdbmsRoot.url -}}
{{- end -}}
{{- if .global -}}
    {{- if .global.rdbms -}}
        {{- $host = .global.rdbms.url -}}
    {{- end -}}
{{- end }}
- name: wait-rdbms
  image: hub.fano.ai/thirdparty/busybox:1.33.0
  imagepullPolicy: IfNotPresent
  command: ['sh', '-c', 'until nslookup {{ $host }}; do echo waiting for {{ $host }}; sleep 2; done;']
{{- end }}

{{/*
Return the rdbms uri
{{ include "speech.rdbms-arg" ( dict "rdbmsRoot" .Values.path.to.the.rdbms "global" $) }}
*/}}
{{- define "speech.rdbms-arg" -}}
{{- $host := "rdbms" -}}
{{- $port := 6379 -}}
{{- $database := "" -}}
{{- $scheme := "http" -}}
{{- $authEnabled := false -}}
{{- $authSecret := "" -}}
{{- $oType := "" -}}
{{- if .rdbmsRoot -}}
    {{- $host = .rdbmsRoot.url -}}
    {{- $port = .rdbmsRoot.port -}}
    {{- $database = .rdbmsRoot.database -}}
    {{- $oType = .rdbmsRoot.type -}}
    {{- $authEnabled = default false .rdbmsRoot.auth.enabled -}}
    {{- if $authEnabled -}}
      {{- $authSecret = .rdbmsRoot.auth.existingSecret -}}
    {{- end -}}
{{- end -}}
{{- if .global -}}
    {{- if .global.rdbms -}}
        {{- $host = .global.rdbms.url -}}
        {{- $port = .global.rdbms.port -}}
        {{- $database = .global.rdbms.database -}}
        {{- $oType = .global.rdbms.type -}}
        {{- $authEnabled = default false .global.rdbms.auth.enabled -}}
        {{- if $authEnabled -}}
          {{- $authSecret = .global.rdbms.auth.existingSecret -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
{{- $typeMap := dict "mssql" "mssql" "mysql" "mysql" "oracle" "oracle" "postgresql" "postgres" -}}
{{- $type := index $typeMap $oType }}
- name: LICENSE_CONTROL_RDBMS_DB_CLIENT
  value: {{ $type }}
- name: LICENSE_CONTROL_RDBMS_DATABASE_NAME
  value: {{ $database }}
- name: LICENSE_CONTROL_RDBMS_SERVER_URL
  value: {{ $host }}
- name: LICENSE_CONTROL_RDBMS_SERVER_PORT
  value: {{ $port | toString | quote }}
- name: LICENSE_CONTROL_RDBMS_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ $authSecret }}
      key: username
- name: LICENSE_CONTROL_RDBMS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ $authSecret }}
      key: password
{{- end }}


{{/*
license postgres client env template
 */}}
{{- define "speech.license-rdbms-client-env" -}}
{{- $typeMap := dict "mssql" "mssql" "mysql" "mysql" "oracle" "oracle" "postgresql" "postgres" }}
{{- $type := index $typeMap .Values.licenseControl.db.type }}
- name: LICENSE_CONTROL_RDBMS_DB_CLIENT
  value: {{ $type }}
- name: LICENSE_CONTROL_RDBMS_DATABASE_NAME
  value: {{ .Values.licenseControl.db.database }}
- name: LICENSE_CONTROL_RDBMS_SERVER_URL
  value: {{ .Values.licenseControl.db.url }}
- name: LICENSE_CONTROL_RDBMS_SERVER_PORT
  value: {{ .Values.licenseControl.db.port | quote }}
- name: LICENSE_CONTROL_RDBMS_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ .Values.licenseControl.db.auth.existingSecret | quote }}
      key: username
- name: LICENSE_CONTROL_RDBMS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.licenseControl.db.auth.existingSecret | quote }}
      key: password
{{- end }}

