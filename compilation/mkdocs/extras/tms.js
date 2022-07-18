// Documentation sur la librairie Géoportail
// https://github.com/IGNF/geoportal-extensions/blob/develop/doc/README-openlayers.md

// Documentation OpenLayers
// https://openlayers.org/en/latest/doc/quickstart.html
// https://openlayers.org/en/latest/apidoc/ol.Map.html

// Récupération du fichier d'autoconf :
// https://wxs.ign.fr/decouverte/autoconf?keys=decouverte,essentiels&gp-access-lib=3.0.5&output=json&callback=callback
// En registrer le résultat dans autoconf.json

// Données "découverte"
// https://geoservices.ign.fr/services-web-decouverte
// Données "essentiels"
// https://geoservices.ign.fr/services-web-essentiels

// TMS PM
// Résolution du niveau 21
var origin_res = 0.0746455354347424;
var origin_x = -20037508.3427892;
var origin_y = 20037508.3427892;

window.onload = function () {
    function style() {
        return [
            new ol.style.Style({
                stroke: new ol.style.Stroke({
                    color: '#ff6600',
                    width: 3,
                })
            })
        ];
    }

    //Création de la Source
    var source = new ol.source.Vector({
        features: []
    });

    //Création de la coche de Markers
    var tms = new ol.layer.Vector({
        source: source
    });


    var fond = new ol.layer.GeoportalWMTS(
        {
            layer: "ORTHOIMAGERY.ORTHOPHOTOS"
        }
    );
    var map = new ol.Map(
        {
            view: new ol.View(
                {
                    center: [670928.74, 5981233.18],
                    zoom: 14,
                    constrainResolution: true,
                    maxZoom: 21
                }
            ),
            target: 'map',
            layers: [
                fond,
                tms
            ]
        }
    );

    var lsControl = new ol.control.LayerSwitcher({
        layers: [{
            layer: tms,
            config: {
                title: "Grille",
                description: "Tile Matrix Set Web Mercator (EPSG:3857)"
            }
        }],
        options: {
            collapsed: true
        }
    });

    //Ajout du controle à la carte
    map.addControl(lsControl);

    var search = new ol.control.SearchEngine();
    map.addControl(search);

    map.on("moveend", function () {
        var zoom = map.getView().getZoom();
        var level_res = origin_res * (2 ** (21 - zoom));
        document.getElementById('infos1').innerHTML = `
        Niveau : ${zoom} (résolution ${level_res} m)
        `;
        document.getElementById('infos2').innerHTML = "";
        var extent = map.getView().calculateExtent(map.getSize());
        source.clear();
        fond.getSource().getTileGrid().forEachTileCoord(extent, zoom, function (tileCoord) {

            var x_min = origin_x + level_res * 256 * tileCoord[1];
            var x_max = origin_x + level_res * 256 * (tileCoord[1] + 1);
            var y_max = origin_y - level_res * 256 * tileCoord[2];
            var y_min = origin_y - level_res * 256 * (tileCoord[2] + 1);

            var feature = new ol.Feature({
                geometry: new ol.geom.Polygon([[[x_min, y_min],[x_min, y_max],[x_max, y_max],[x_max, y_min],[x_min, y_min]]]),
            });

            //on lui applique le style
            feature.setStyle(style);
            source.addFeature(feature);
        });
    });

    map.on('click', function (evt) {
        var zoom = map.getView().getZoom();
        var level_res = origin_res * (2 ** (21 - zoom));
        var row = Math.floor((origin_y - evt.coordinate[1]) / (256 * level_res));
        var column = Math.floor((evt.coordinate[0] - origin_x) / (256 * level_res));
        var url = fond.getSource().tileUrlFunction([zoom, column, row]);
        document.getElementById('infos2').innerHTML = `
        X/Y (${evt.coordinate[0]}, ${evt.coordinate[1]}), COL/ROW : (${column}, ${row}), <a target="_blank" href="${url}">GetTile</a>
        `;
    });
}