{{/* helpers.tpl */}}

{{- define "ClusterResourceSet.AddonsFalse" -}}
{{- $allFalse := true }}
{{- range . }}
  {{- if . }}
    {{- $allFalse = false }}
  {{- end }}
{{- end }}
{{- if and (not $allFalse) (len .) }}{{- else -}}{}{{- end }}
{{- end -}}

{{- define "worker.replicas" -}}
{{- $replicas := lookup "v1" "machinedeployments.cluster.x-k8s.io" "capi-dev" "capi-dev-md-0" -}}
{{- with $replicas -}}
{{- with index . "spec" -}}
{{ .replicas }}
{{- else -}}
{{ .Values.cluster.workerNodeReplicas }}
{{- end }}
{{- else -}}
{{ .Values.cluster.workerNodeReplicas }}
{{- end }}
{{- end }}