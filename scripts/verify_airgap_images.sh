[root@bcm10-rhel ~]# cat /root/airgapped/verify_airgap_images.sh 
#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/root/airgapped"
CHART_DIR="$BASE_DIR/helm-charts"
IMAGES_DIR="$BASE_DIR/k8s-images"
WORKDIR="/tmp/airgap-audit"

rm -rf "$WORKDIR"
mkdir -p "$WORKDIR/charts"

echo ">> Extracting helm charts..."
for tgz in "$CHART_DIR"/*.tgz; do
  tar xzf "$tgz" -C "$WORKDIR/charts"
done

echo ">> Collecting images from helm templates..."
> "$WORKDIR/images.from.template"
for chart in "$WORKDIR/charts"/*; do
  helm template "$chart" --namespace dummy 2>/dev/null \
    | grep -E 'image:' \
    | awk '{print $2}' \
    | sed 's/"//g' \
    >> "$WORKDIR/images.from.template" || true
done

echo ">> Collecting images from values.yaml and templates..."
> "$WORKDIR/images.from.sources"
grep -R "repository:" "$WORKDIR/charts" \
  | awk '{print $2}' \
  >> "$WORKDIR/images.from.sources" || true

grep -R "image:" "$WORKDIR/charts" \
  | awk '{print $2}' \
  | sed 's/"//g' \
  >> "$WORKDIR/images.from.sources" || true

echo ">> Normalizing required images..."
cat "$WORKDIR/images.from.template" "$WORKDIR/images.from.sources" \
  | sed 's/@sha256:.*//' \
  | grep -E '[a-zA-Z0-9._-]+/[a-zA-Z0-9._/-]+:[a-zA-Z0-9._-]+' \
  | sort -u \
  > "$WORKDIR/images.required"

echo ">> Extracting images from loaded tar archives..."
> "$WORKDIR/images.present"
for tarf in "$IMAGES_DIR"/*.tar; do
  tar -tf "$tarf" \
    | grep manifest.json >/dev/null || continue

  tar -xOf "$tarf" manifest.json \
    | jq -r '.[].RepoTags[]?' \
    >> "$WORKDIR/images.present"
done

sort -u "$WORKDIR/images.present" > "$WORKDIR/images.present.sorted"

echo ">> Computing missing images..."
comm -23 \
  <(sort "$WORKDIR/images.required") \
  <(sort "$WORKDIR/images.present.sorted") \
  > "$WORKDIR/images.missing"

echo
echo "==================== SUMMARY ===================="
echo "Required images : $(wc -l < $WORKDIR/images.required)"
echo "Present images  : $(wc -l < $WORKDIR/images.present.sorted)"
echo "Missing images  : $(wc -l < $WORKDIR/images.missing)"
echo "================================================="
echo
echo "Missing images list:"
cat "$WORKDIR/images.missing"
echo
echo "Files generated in $WORKDIR"