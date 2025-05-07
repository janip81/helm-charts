{{- define "k8s-ui.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "k8s-ui.fullname" -}}
{{- printf "%s" (include "k8s-ui.name" .) -}}
{{- end }}
