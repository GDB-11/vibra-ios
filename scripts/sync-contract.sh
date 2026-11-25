#!/usr/bin/env bash
# Copia el contrato OpenAPI de vibra-contracts al paquete Networking.
# La copia no se edita a mano: cambia el contrato en su repositorio y vuelve a sincronizar.
# Variable opcional: VIBRA_CONTRACTS_DIR (por defecto, ../vibra-contracts).
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
contracts_dir="${VIBRA_CONTRACTS_DIR:-$root/../vibra-contracts}"
source_file="$contracts_dir/openapi.json"
target_file="$root/Packages/Networking/Sources/Networking/openapi.json"

if [[ ! -f "$source_file" ]]; then
  echo "Error: no se encontró $source_file" >&2
  exit 1
fi

# Se valida antes de copiar para no reemplazar una copia buena con un documento inválido.
# swift-openapi-generator no admite todavía 3.2 de forma estable (decisión 005).
python3 -I - "$source_file" <<'PY'
import json, sys

try:
    with open(sys.argv[1], encoding="utf-8") as file:
        version = str(json.load(file)["openapi"])
except (ValueError, KeyError, TypeError) as error:
    sys.exit(f"Error: {sys.argv[1]} no es un documento OpenAPI válido ({error!r})")
if not version.startswith("3.1."):
    sys.exit(f"Error: se esperaba OpenAPI 3.1.x y se obtuvo {version}")
PY

cp "$source_file" "$target_file"
echo "Contrato sincronizado en ${target_file#"$root"/}. Vuelve a compilar para regenerar el cliente."
