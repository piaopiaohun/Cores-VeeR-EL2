# !/bin/bash
PREFIX="FOOBAR"
DEFINES_PATH="../verification/block/snapshots/default"
COMMON_DEFINES="$DEFINES_PATH/common_defines.vh"
EL2_PARAM="$DEFINES_PATH/el2_param.vh"
EL2_PDEF="$DEFINES_PATH/el2_pdef.vh"
PD_DEFINES="$DEFINES_PATH/pd_defines.vh"


DEFINES_REGEX="s/((\`define)|(\`ifndef)|(\`undef)) ([A-Z0-9_]+).*/\5/p"
DEFINES="$(sed -nr "$DEFINES_REGEX" $COMMON_DEFINES $PD_DEFINES | sort -ur)"
DESIGN_FILES="$(find ../design ../verification -name "*.sv" -o -name "*.vh")"


sed -E "s/((\`define)|(\`ifndef)|(\`undef)) ([A-Z0-9_]+)/\1 "$PREFIX"_\5/" $COMMON_DEFINES >  $DEFINES_PATH/"$PREFIX"_common_defines.vh
sed -E "s/((\`define)|(\`ifndef)|(\`undef)) ([A-Z0-9_]+)/\1 "$PREFIX"_\5/" $PD_DEFINES >  $DEFINES_PATH/"$PREFIX"_pd_defines.vh


for DEFINE in $DEFINES; do
    sed -i "s/\`$DEFINE/\`"$PREFIX"_$DEFINE/g" $DESIGN_FILES
done

STRUCT_SED="s/el2_param_t/"$PREFIX"_el2_param_t/g"
sed "$STRUCT_SED" "$EL2_PARAM" > $DEFINES_PATH/"$PREFIX"_el2_param.vh
sed "$STRUCT_SED" "$EL2_PDEF" > $DEFINES_PATH/"$PREFIX"_el2_pdef.vh
sed -i "$STRUCT_SED" $DESIGN_FILES

sed -i "s/include \"el2_param.vh\"/include \""$PREFIX"_el2_param.vh\"/g" $DESIGN_FILES
sed -i "s/include \"el2_pdef.vh\"/include \""$PREFIX"_el2_pdef.vh\"/g" $DESIGN_FILES

sed -i "s/import el2_pkg/import "$PREFIX"_el2_pkg/g" $DESIGN_FILES
sed -i "s/package el2_pkg/package "$PREFIX"_el2_pkg/g" ../design/include/el2_def.sv


MODULES_REGEX="s/^module ([A-Za-z0-9_]+).*/\1/p"
MODULES="$(sed -nr "$MODULES_REGEX" $DESIGN_FILES | sort -ur)"

echo $MODULES

sed -i -E "s/module ([A-Za-z0-9_]+)/module "$PREFIX"_\1/g" $DESIGN_FILES

for MODULE in $MODULES; do
    sed -i -E "s/[^A-Za-z0-9_]$MODULE[^A-Za-z0-9_]/"$PREFIX"_$MODULE /g" $DESIGN_FILES
done
