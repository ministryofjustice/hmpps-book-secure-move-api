.PHONY: all

all: moves.png journeys.png

%.png: %.dot
	dot -Tpng $< -o $@

clean:
	rm -f *.png
