{{/*
Expand the name of the chart.
*/}}
{{- define "node-bootstrap.name" -}}
node-bootstrap
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "node-bootstrap.fullname" -}}
{{ include "node-bootstrap.name" . }}-{{ .Release.Name }}
{{- end }}

{{- define "node-bootstrap.labels" -}}
app.kubernetes.io/name: {{ include "node-bootstrap.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Resolve which Secret name/key holds the fetch bearer token.
*/}}
{{- define "node-bootstrap.fetchTokenSecretName" -}}
{{- if .Values.fetchToken.existingSecret -}}
{{ .Values.fetchToken.existingSecret }}
{{- else -}}
{{ include "node-bootstrap.fullname" . }}-fetch-token
{{- end -}}
{{- end }}

{{- define "node-bootstrap.fetchTokenSecretKey" -}}
{{- if .Values.fetchToken.existingSecret -}}
{{ .Values.fetchToken.existingSecretKey }}
{{- else -}}
fetch-token
{{- end -}}
{{- end }}
