cat <<EOF > cloudbuild.yaml
steps:
# 1. Step: job_script.py file ko GCS bucket mein copy karna
- name: 'gcr.io/cloud-builders/gsutil'
  id: 'Deploy Job Script'
  args:
    - 'cp'
    - 'zaff123.py'
    - 'gs://my_rev_buckets_123/scripts/job_script.py'

# 2. Step: Docker Image banana
- name: 'gcr.io/cloud-builders/docker'
  id: 'Build Image'
  args: ['build', '-t', 'us-central1-docker.pkg.dev/\$PROJECT_ID/my-docker-repo/zaff-app:\$COMMIT_SHA', '.']

# 3. Step: Image ko Artifact Registry mein Push karna (SHA tag)
- name: 'gcr.io/cloud-builders/docker'
  id: 'Push Image'
  args: ['push', 'us-central1-docker.pkg.dev/\$PROJECT_ID/my-docker-repo/zaff-app:\$COMMIT_SHA']

# 4. Step: Image ko 'latest' tag dena
- name: 'gcr.io/cloud-builders/docker'
  id: 'Tag Latest'
  args: ['tag', 'us-central1-docker.pkg.dev/\$PROJECT_ID/my-docker-repo/zaff-app:\$COMMIT_SHA', 'us-central1-docker.pkg.dev/\$PROJECT_ID/my-docker-repo/zaff-app:latest']

# 5. Step: 'latest' tagged Image ko Artifact Registry mein Push karna
- name: 'gcr.io/cloud-builders/docker'
  id: 'Push Latest'
  args: ['push', 'us-central1-docker.pkg.dev/\$PROJECT_ID/my-docker-repo/zaff-app:latest']

options:
  logging: CLOUD_LOGGING_ONLY
substitutions:
  _REGION: us-central1
EOF
