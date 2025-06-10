SCHEMATIC_ID=aabbccddeeff11223344556677889900abcdeff01234567890abcdef12345678
VERSION=v1.10.3
IMAGE="factory.talos.dev/metal-installer/$SCHEMATIC_ID:$VERSION"

for ip in 10.57.57.80 10.57.57.82 10.57.57.84 10.57.57.81 10.57.57.83 10.57.57.85; do
  talosctl -n $ip upgrade --image $IMAGE --preserve
done