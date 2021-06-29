Youtube link: https://www.youtube.com/watch?v=5_J7RWLLVeQ&t=530s
Git hib repo: https://github.com/marcel-dempers/docker-development-youtube-series

# Create Helm chart
 - helm create example-app #Create chart
# The folder templates of the helm chart includes all the required files for creating the application (deployments, service, configmap, secret)

# Check the chart render
 - Pattern: helm template [NAME] [CHART-FOLDER]
 - helm template example-app example-app

# Install chart
 - helm install example-app example-app
 - helm install example-app-2 example-app -f example-app/values-app2.yaml

# Use .Values variable
- Go to each of the YAML files under "templates: folder and add the path, for example:
  inside values.yaml we will have:
  deployment:
    image: "aimvector/python"
  Under deployment.yaml we will set
  image: {{ .Values.deployment.image }}:{{ .Values.deployment.tag }}

# If else
{{- if .Values.deployment.resources }} # Check if value is empty
        resources:
          {{- if .Values.deployment.resources.requests }}
          requests:
            memory: {{ .Values.deployment.resources.requests.memory | default "50Mi" | quote }} --> If it empty, it will add the values and add "quote"
            cpu: {{ .Values.deployment.resources.requests.cpu | default "10m" | quote }}
          {{- else}}
          requests:
            memory: "50Mi"
            cpu: "10m"
          {{- end}}
          {{- if .Values.deployment.resources.limits }}
          limits:
            memory: {{ .Values.deployment.resources.limits.memory | default "1024Mi" | quote }}
            cpu: {{ .Values.deployment.resources.limits.cpu | default "1" | quote }}
          {{- else}}  
          limits:
            memory: "1024Mi"
            cpu: "1"
          {{- end }}
        {{- else }}
        resources:
          requests:
            memory: "50Mi"
            cpu: "10m"
          limits:
            memory: "1024Mi"
            cpu: "1"
        {{- end}}  