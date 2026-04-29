{{- define "claude-memory.name" -}}
{{- .Chart.Name }}
{{- end }}

{{- define "claude-memory.fullname" -}}
{{- .Release.Name }}-{{ .Chart.Name }}
{{- end }}

{{- define "claude-memory.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: {{ include "claude-memory.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "claude-memory.selectorLabels" -}}
app.kubernetes.io/name: {{ include "claude-memory.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
