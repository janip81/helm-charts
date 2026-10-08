{{- define "alertmanager-mqtt-bridge.name" -}}
alertmanager-mqtt-bridge
{{- end }}

{{- define "alertmanager-mqtt-bridge.fullname" -}}
{{- if eq .Release.Name (include "alertmanager-mqtt-bridge.name" .) -}}
{{ .Release.Name }}
{{- else -}}
{{ include "alertmanager-mqtt-bridge.name" . }}-{{ .Release.Name }}
{{- end -}}
{{- end }}

{{- define "alertmanager-mqtt-bridge.labels" -}}
app.kubernetes.io/name: {{ include "alertmanager-mqtt-bridge.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}

{{- define "alertmanager-mqtt-bridge.selectorLabels" -}}
app.kubernetes.io/name: {{ include "alertmanager-mqtt-bridge.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "alertmanager-mqtt-bridge.mqttSecret" -}}
{{- if .Values.mqtt.existingSecret -}}
{{ .Values.mqtt.existingSecret }}
{{- else if .Values.mqtt.createSecret -}}
{{ include "alertmanager-mqtt-bridge.fullname" . }}-mqtt
{{- end -}}
{{- end }}
