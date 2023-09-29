{{/* helpers.tpl */}}

{{- define "ClusterResourceSet.AddonsFalse" -}}
{{- $allFalse := true }}
{{- range . }}
  {{- if . }}
    {{- $allFalse = false }}
  {{- end }}
{{- end }}
{{- if and (not $allFalse) (len .) }}{{- else -}}[]{{- end }}
{{- end -}}

{{- define "worker.replicas" -}}
{{- $replicas := lookup "v1" "machinedeployments.cluster.x-k8s.io" "capi-dev" "{{ .name }}" -}}
{{- with $replicas -}}
{{- with index . "spec" -}}
{{ .replicas }}
{{- else -}}
{{ .replicas }}
{{- end }}
{{- else -}}
{{ .replicas }}
{{- end }}
{{- end }}