{{- define "gameledger.name" -}}
{{- .Chart.Name }}
{{- end }}

{{- define "gameledger.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "gameledger.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gameledger.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
