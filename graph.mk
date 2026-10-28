.DEFAULT_GOAL := help

# このリポジトリ固有のmakeのターゲット。Makefileが-includeで読む。
# Makefileはテンプレートと共通なので、ここに書く（下の層のテンプレートはgraph.mkを配らない）。

.PHONY: ci

# GitHub Actionsが動かないときに、graph-check.ymlと同じ検査を手元で回す。
# PRの番号を渡すと、PRのときにしか走らないrefsとnamesも回す。
#
#     make ci PR=17
ci:
	$(PYTHON) scripts/local_ci.py $(PR)

# --------------------------------------------------------------------------
# ここから下は作品が足すもの（PDR-0015）
# --------------------------------------------------------------------------
# README_GRAPH_ARGSや作品のターゲットは、この下に書く。このファイルはmerge=oursではないので、
# 上のこの層の行と離して書くと、取り込みで競合しにくい。

README_GRAPH_ARGS = --hide-edges decides
