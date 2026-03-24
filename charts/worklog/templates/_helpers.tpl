{{/*
Expand the name of the chart.
*/}}
{{- define "worklog.name" -}}
{{- .Chart.Name }}
{{- end }}

{{- define "worklog.api.name" -}}
{{- printf "%s-api" .Chart.Name }}
{{- end }}

{{- define "worklog.frontend.name" -}}
{{- printf "%s-frontend" .Chart.Name }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "worklog.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "worklog.api.selectorLabels" -}}
app.kubernetes.io/name: {{ include "worklog.api.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "worklog.frontend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "worklog.frontend.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
