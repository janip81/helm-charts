{{/* helpers.tpl */}}

{{- define "ClusterResourceSet.AddonsFalse" -}}
{{- $allFalse := true }}
{{- range . }}
  {{- if . }}
    {{- $allFalse = false }}
  {{- end }}
{{- end }}
{{- if $allFalse }}{}{{- end }}
{{- end -}}