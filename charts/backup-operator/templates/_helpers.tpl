{{- define "backup-operator.labels" -}}
app.kubernetes.io/name: backup-operator
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
{{- end }}

{{- define "backup-operator.selectorLabels" -}}
app.kubernetes.io/name: backup-operator
{{- end }}
