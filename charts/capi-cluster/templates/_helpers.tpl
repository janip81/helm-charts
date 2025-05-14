{{/* helpers.tpl */}}

{{- define "worker.replicas" -}}
{{- .replicas | default 1 }}
{{- end }}
