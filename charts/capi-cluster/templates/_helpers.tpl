{{/* helpers.tpl */}}

{{- define "worker.replicas" -}}
{{- .replicas | default 1 }}
{{- end }}

{{/*
etcd.image returns the etcd container image that matches the cluster's k8s minor version.
Override by setting etcdDefrag.image in values.
*/}}
{{- define "etcd.image" -}}
{{- $v := .Values.controlPlaneNodes.k8sVersion -}}
{{- $parts := splitList "." $v -}}
{{- $minor := index $parts 1 | int -}}
{{- if eq $minor 35 -}}registry.k8s.io/etcd:3.6.6-0
{{- else if eq $minor 34 -}}registry.k8s.io/etcd:3.6.4-0
{{- else if eq $minor 33 -}}registry.k8s.io/etcd:3.5.21-0
{{- else if eq $minor 32 -}}registry.k8s.io/etcd:3.5.16-0
{{- else if eq $minor 31 -}}registry.k8s.io/etcd:3.5.15-0
{{- else if eq $minor 30 -}}registry.k8s.io/etcd:3.5.12-0
{{- else -}}
{{- fail (printf "etcdDefrag: no known etcd image for k8s 1.%d — set etcdDefrag.image manually" $minor) -}}
{{- end -}}
{{- end }}
