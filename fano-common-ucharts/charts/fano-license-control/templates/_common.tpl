{{/*
Return the proper image name
{{ include "common.images.image" ( dict "imageRoot" .Values.path.to.the.image "global" $) }}
*/}}
{{- define "common.images.image" -}}
{{- $registryName := .imageRoot.registry -}}
{{- $repositoryName := .imageRoot.repository -}}
{{- $tag := .imageRoot.tag | toString -}}
{{- if .global }}
    {{- if .global.imageRegistry }}
     {{- $registryName = .global.imageRegistry -}}
    {{- end -}}
{{- end -}}
{{- if $registryName }}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
{{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names (deprecated: use common.images.renderPullSecrets instead)
{{ include "common.images.pullSecrets" ( dict "images" (list .Values.path.to.the.image1, .Values.path.to.the.image2) "global" .Values.global) }}
*/}}
{{- define "common.images.pullSecrets" -}}
  {{- $pullSecrets := list }}

  {{- if .global }}
    {{- range .global.imagePullSecrets -}}
      {{- $pullSecrets = append $pullSecrets . -}}
    {{- end -}}
  {{- end -}}

  {{- range .images -}}
    {{- range .pullSecrets -}}
      {{- $pullSecrets = append $pullSecrets . -}}
    {{- end -}}
  {{- end -}}

  {{- if (not (empty $pullSecrets)) }}
imagePullSecrets:
    {{- range $pullSecrets }}
  - name: {{ . }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
db url template
{{ include "common.db-url" ( dict "scheme" .Values.to.scheme "host" .Values.to.url "port" .Value.to.port "database" .Values.to.database "usernameEnv" .Value.to.usernameEnv "passwordEnv" .Value.to.passwordEnv ) }}
 */}}
{{- define "common.db-url" -}}
{{- $host := printf "%s:%s" .host (.port | toString ) }}
{{- $database := "" }}
{{- if .database -}}
{{- $database = printf "/%s" .database }}
{{- end -}}
{{- $scheme := .scheme }}
{{- $auth := "" -}}
{{- if and .usernameEnv .passwordEnv -}}
{{- $auth = printf "$(%s)$(%s)@" .usernameEnv .passwordEnv -}}
{{- end -}}
{{- print $scheme "://" $auth $host $database }}
{{- end -}}

{{/*
common parse cpu
{{ include "common.parse-cpu" .Values.to.resource ) }}
 */}}
{{- define "common.parse-cpu" -}}
{{- $value := "1" -}}
{{- $cpu := 1 -}}
{{- if . -}}
  {{- if .requests -}}
    {{- $value = ( .requests.cpu | default "1" | toString ) -}}
  {{- end -}}
  {{- if .limits -}}
    {{- $value = ( .limits.cpu | default "1" | toString ) -}}
  {{- end -}}
{{- end -}}
{{- if hasSuffix "m" $value -}}
{{- $cpu = div (atoi (split "m" $value)._0) 1000 -}}
{{- else -}}
{{- $cpu = float64 $value -}}
{{- end -}}
{{- printf "%d" (int (floor $cpu)) }}
{{- end -}}
