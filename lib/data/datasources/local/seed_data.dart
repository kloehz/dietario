class MenuSeed {
  static List<Map<String, Object?>> build() {
    final List<List<String>> grid = [
      // [day, slot, text, menuCode]
      ['Lunes', 'desayuno', 'Yogur natural + quinoa pop + manzana. + 1 cítrico por persona.', 'MENÚ 1'],
      ['Lunes', 'almuerzo', 'Omelette de 2 huevos por persona relleno de espinaca + queso magro + ensalada de repollo, lentejas y zanahoria + semillas.', 'MENÚ 1'],
      ['Lunes', 'merienda', 'Fruta + puñado de frutos secos.', 'MENÚ 1'],
      ['Lunes', 'cena', 'Medallón casero de pescado + ensalada de zanahoria, repollo, arroz integral y tomate + limón.', 'MENÚ 1'],
      ['Martes', 'desayuno', 'Tostón de pan de trigo sarraceno/legumbres + pasta de maní + queso untable. + 1 cítrico por persona.', 'MENÚ 2'],
      ['Martes', 'almuerzo', '2 medallones de lentejas por persona + 1/2 plato de ensalada de 3 vegetales.', 'MENÚ 2'],
      ['Martes', 'merienda', 'Yogur natural + frutos rojos.', 'MENÚ 2'],
      ['Martes', 'cena', 'Filet de pollo al romero, mostaza y limón + verduras al horno: calabaza, berenjena, zanahoria y cebolla.', 'MENÚ 2'],
      ['Miércoles', 'desayuno', 'Avena con cacao amargo, coco rallado y frutos rojos. + 1 cítrico por persona.', 'MENÚ 3'],
      ['Miércoles', 'almuerzo', 'Filet de merluza + ensalada de remolacha, papa y huevo + semillas.', 'MENÚ 3'],
      ['Miércoles', 'merienda', 'Tostón dulce con pasta de maní + queso untable + manzana.', 'MENÚ 3'],
      ['Miércoles', 'cena', 'Albóndigas de lentejas + ensalada tibia de calabaza, huevo y tomate.', 'MENÚ 3'],
      ['Jueves', 'desayuno', 'Yogur natural + banana + frutos secos. + 1 cítrico por persona.', 'MENÚ 4'],
      ['Jueves', 'almuerzo', 'Milanesas de pechuga rebozadas con avena y semillas + croquetas de verdura.', 'MENÚ 4'],
      ['Jueves', 'merienda', 'Avena con cacao amargo, coco rallado y frutos rojos.', 'MENÚ 4'],
      ['Jueves', 'cena', 'Wok de caballa o atún con zucchini, morrón, cebolla y ajo + nueces o aceite de lino.', 'MENÚ 4'],
      ['Viernes', 'desayuno', 'Tostón con hummus + tomates cherry + 1 huevo por persona. + 1 cítrico por persona.', 'MENÚ 5'],
      ['Viernes', 'almuerzo', 'Omelette de 3 huevos por persona con espinaca + jardinera enjuagada.', 'MENÚ 5'],
      ['Viernes', 'merienda', 'Yogur natural + quinoa pop + banana.', 'MENÚ 5'],
      ['Viernes', 'cena', 'Tarta de atún y cebolla (1 sola tapa con semillas) + ensalada de zanahoria y repollo.', 'MENÚ 5'],
      ['Sábado', 'desayuno', 'Yogur natural + manzana + frutos secos. + 1 cítrico por persona.', 'MENÚ 6'],
      ['Sábado', 'almuerzo', 'Filet de pollo al limón, romero y mostaza + ensalada de 3 vegetales.', 'MENÚ 6'],
      ['Sábado', 'merienda', 'Fruta + puñado de frutos secos.', 'MENÚ 6'],
      ['Sábado', 'cena', 'Puré mixto papa-calabaza + jurel/pescado + limón, perejil y ajo + ensalada verde opcional.', 'MENÚ 6'],
      ['Domingo', 'desayuno', 'Pancakes/waffles caseros + pasta de maní + queso untable. + 1 cítrico por persona.', 'MENÚ 7'],
      ['Domingo', 'almuerzo', 'Fideos de zucchini con salsa verde de acelga/espinaca y salsa blanca liviana. Queso rallado opcional.', 'MENÚ 7'],
      ['Domingo', 'merienda', 'Yogur natural + fruta.', 'MENÚ 7'],
      ['Domingo', 'cena', 'Albóndigas de arvejas + puré mixto + ensalada de champiñones y rúcula.', 'MENÚ 7'],
    ];

    return List.generate(grid.length, (i) {
      final r = grid[i];
      return <String, Object?>{
        'id': i + 1,
        'day': r[0],
        'slot': r[1],
        'text': r[2],
        'menu_code': r[3],
        'note': null,
        'order_index': i,
      };
    });
  }
}

class ShoppingSeed {
  static List<Map<String, Object?>> build() {
    final List<List<Object>> rows = [
      // [category, product, quantity, unit, notes]
      ['Verdulería', 'Zanahoria', 2, 'kg', 'Ensaladas, croquetas, medallones y verduras al horno'],
      ['Verdulería', 'Repollo', 1, 'unidad mediana/grande', 'Ensaladas de MENÚ 1 y 5'],
      ['Verdulería', 'Espinaca y/o acelga', 1.2, 'kg aprox.', 'Omelettes + salsa verde; puede ser fresca o congelada'],
      ['Verdulería', 'Tomate', 1.5, 'kg', 'Ensaladas y acompañamientos'],
      ['Verdulería', 'Tomates cherry', 250, 'g', 'Tostón con hummus'],
      ['Verdulería', 'Calabaza', 2.5, 'kg', 'Horno, ensalada tibia y purés'],
      ['Verdulería', 'Papa', 1.5, 'kg', 'Ensalada y purés mixtos'],
      ['Verdulería', 'Zucchini / zapallito', 2, 'kg', 'Wok, croquetas y fideos de zucchini'],
      ['Verdulería', 'Berenjena', 2, 'unidades', 'Verduras al horno'],
      ['Verdulería', 'Remolacha', 4, 'unidades', 'Ensalada con merluza'],
      ['Verdulería', 'Morrón', 4, 'unidades', 'Wok, croquetas/albóndigas y extras'],
      ['Verdulería', 'Cebolla', 2, 'kg', 'Base de varias preparaciones'],
      ['Verdulería', 'Ajo', 3, 'cabezas', 'Condimento y preparaciones'],
      ['Verdulería', 'Rúcula / hojas verdes', 500, 'g', 'Ensaladas y acompañamientos'],
      ['Verdulería', 'Champiñones', 300, 'g', 'Cena del domingo'],
      ['Verdulería', 'Limón', 10, 'unidades', 'Pescado, pollo, ensaladas y hummus'],
      ['Verdulería', 'Perejil', 2, 'atados', 'Pescado, jurel y albóndigas'],
      ['Verdulería', 'Romero', 1, 'atado', 'Pollo; también puede ser seco'],
      ['Frutas', 'Mandarina / naranja / pomelo', 14, 'unidades', '1 cítrica por persona por día'],
      ['Frutas', 'Manzana', 6, 'unidades', 'Desayunos/meriendas'],
      ['Frutas', 'Banana', 6, 'unidades', 'Desayunos/meriendas'],
      ['Frutas', 'Frutos rojos', 600, 'g', 'Frescos o congelados'],
      ['Proteínas', 'Huevos', 30, 'unidades', 'Omelettes, ensaladas, rebozados y desayunos'],
      ['Proteínas', 'Pechuga de pollo', 1.7, 'kg', '3 comidas principales; porcionar y freezar'],
      ['Proteínas', 'Merluza / pescado blanco', 1, 'kg', 'Medallones + filet del miércoles'],
      ['Proteínas', 'Atún al natural', 3, 'latas', 'Tarta + 1 lata de respaldo'],
      ['Proteínas', 'Caballa', 2, 'latas', 'Wok del jueves'],
      ['Proteínas', 'Jurel', 2, 'latas', 'Puré mixto del sábado; puede reemplazarse por pescado'],
      ['Lácteos', 'Yogur natural sin azúcar', 2.5, 'kg', 'Desayunos y meriendas'],
      ['Lácteos', 'Queso magro', 300, 'g', 'Omelettes y opcional en salsa'],
      ['Lácteos', 'Queso untable proteico / magro', 300, 'g', 'Tostones y pancakes'],
      ['Lácteos', 'Leche o bebida vegetal sin azúcar', 1, 'litro', 'Salsa blanca liviana y pancakes'],
      ['Legumbres', 'Lentejas secas', 500, 'g', 'Cocinar aprox. 350 g secos y freezar sobrante'],
      ['Legumbres', 'Arvejas', 500, 'g', 'Congeladas o 2 latas enjuagadas'],
      ['Legumbres', 'Garbanzos', 2, 'latas', 'Para hummus; o 250 g secos'],
      ['Cereales', 'Avena arrollada', 1, 'kg', 'Rebozados, medallones, croquetas y desayunos'],
      ['Cereales', 'Arroz integral', 500, 'g', 'Cocinar y enfriar al menos 6 h antes de usar si es posible'],
      ['Cereales', 'Quinoa pop', 250, 'g', 'Yogur/desayunos'],
      ['Panificados', 'Pan de trigo sarraceno / legumbres', 2, 'panes chicos', 'Ideal 2 variedades para alternar'],
      ['Panificados', 'Masa de tarta sin gluten', 1, 'paquete', 'Usar 1 sola tapa; la grilla sugiere Oralí'],
      ['Despensa', 'Harina integral', 500, 'g', 'Albóndigas de arvejas / reemplazable por avena molida'],
      ['Despensa', 'Maicena', 250, 'g', 'Salsa blanca liviana'],
      ['Grasas', 'Aceite de oliva extra virgen', 500, 'ml', 'Preferentemente envase oscuro/lata'],
      ['Grasas', 'Aceite de lino', 250, 'ml', 'Opcional: puede reemplazarse por nueces'],
      ['Grasas', 'Frutos secos / nueces', 400, 'g', 'Puñados en desayunos/meriendas y wok'],
      ['Grasas', 'Pasta de maní sin azúcar', 350, 'g', 'Desayunos/meriendas + hummus si se desea'],
      ['Semillas', 'Semillas de zapallo', 100, 'g', 'Prioridad del plan'],
      ['Semillas', 'Chía', 100, 'g', 'Desayunos o alternar'],
      ['Semillas', 'Sésamo', 100, 'g', 'Ensaladas y rebozados'],
      ['Despensa', 'Cacao amargo', 200, 'g', 'Avena y postres'],
      ['Despensa', 'Coco rallado', 100, 'g', 'Avena/desayunos'],
      ['Condimentos', 'Mostaza', 1, 'frasco', 'Pollo y preparaciones'],
      ['Condimentos', 'Cúrcuma', 1, 'frasco', 'Arroz, legumbres y verduras'],
      ['Condimentos', 'Comino', 1, 'frasco', 'Legumbres'],
      ['Condimentos', 'Pimentón', 1, 'frasco', 'Legumbres y carnes'],
      ['Condimentos', 'Pimienta negra', 1, 'frasco', 'Uso general'],
      ['Condimentos', 'Orégano', 1, 'frasco', 'Uso general'],
      ['Condimentos', 'Ajo en polvo', 1, 'frasco', 'Rebozados y croquetas'],
      ['Condimentos', 'Canela', 1, 'frasco', 'Avena/pancakes'],
      ['Condimentos', 'Vinagre de alcohol', 500, 'ml', 'Ensaladas'],
      ['Enlatados', 'Jardinera', 1, 'lata grande', 'Enjuagar antes de consumir'],
    ];

    return List.generate(rows.length, (i) {
      final r = rows[i];
      return <String, Object?>{
        'id': i + 1,
        'category': r[0] as String,
        'product': r[1] as String,
        'quantity': r[2],
        'unit': r[3] as String,
        'notes': r[4] as String,
        'status': 'pendiente',
        'order_index': i,
      };
    });
  }
}

class RecipeSeed {
  static List<Map<String, Object?>> build() {
    final List<List<String>> rows = [
      ['Lunes', 'Almuerzo', 'Omelette de espinaca + ensalada de repollo y lentejas',
        '4 huevos; 200 g espinaca; 80 g queso magro; 250 g repollo; 2 zanahorias; 120 g lentejas cocidas; 2 cditas semillas; limón/oliva.',
        '1) Saltear o cocinar la espinaca. 2) Batir 2 huevos por persona y hacer los omelettes; rellenar con espinaca y queso. 3) Mezclar repollo, zanahoria rallada y lentejas. 4) Terminar con semillas y limón.',
        'Grilla · MENÚ 1'],
      ['Lunes', 'Cena', 'Medallón casero de pescado + ensalada con arroz integral',
        '400 g merluza; 1 huevo; 4 cdas avena molida; perejil/pimienta. Ensalada: 2 zanahorias; 200 g repollo; 150 g arroz integral cocido; 2 tomates; 1 limón.',
        '1) Picar/procesar el pescado. 2) Mezclar con huevo, avena y condimentos; formar medallones. 3) Hornear a 180 °C aprox. 12–15 min, hasta cocción completa. 4) Servir con la ensalada y limón.',
        'Adaptación de grilla + recetario de merluza'],
      ['Martes', 'Almuerzo', 'Medallones de lentejas + ensalada de 3 vegetales',
        '2 tazas lentejas cocidas; 1 zanahoria; 1 cebolla; 1 diente ajo; 1 huevo; 1 taza avena; perejil. Ensalada: tomate, zanahoria y hojas verdes.',
        '1) Pisar/procesar las lentejas. 2) Cocinar cebolla y ajo; rallar la zanahoria. 3) Integrar con huevo, avena y perejil. 4) Formar 4 medallones y hornear ~20 min, dándolos vuelta cuando la base esté firme. 5) Acompañar con ensalada.',
        'Recetario legumbrero'],
      ['Martes', 'Cena', 'Pollo al romero, mostaza y limón + verduras al horno',
        '500 g pechuga; 500 g calabaza; 1 berenjena; 2 zanahorias; 2 cebollas; 1 limón; mostaza; romero; pimienta; oliva.',
        '1) Marinar el pollo con limón, mostaza, romero y pimienta. 2) Cortar las verduras y hornear a 180–200 °C hasta tiernas. 3) Cocinar el pollo a la plancha/horno hasta cocción completa. 4) Servir mitad pollo y mitad verduras.',
        'Grilla · MENÚ 2 / receta de pollo del recetario'],
      ['Miércoles', 'Almuerzo', 'Merluza + ensalada de remolacha, papa y huevo',
        '400 g merluza; 2 remolachas; 400 g papa; 2 huevos; 2 cditas semillas; limón; pimienta/perejil.',
        '1) Hervir papa y remolacha; enfriar. 2) Hervir los huevos. 3) Cocinar la merluza al horno o plancha. 4) Cortar la ensalada, sumar huevo y semillas. 5) Condimentar con limón.',
        'Grilla · MENÚ 3'],
      ['Miércoles', 'Cena', 'Albóndigas de lentejas + ensalada tibia de calabaza',
        '2 tazas lentejas cocidas; 1 zanahoria; 1 cebolla; 1 ajo; 1 huevo; 1 taza avena; perejil. Ensalada: 500 g calabaza; 2 huevos; 2 tomates.',
        '1) Preparar una mezcla como la de medallones de lenteja y formar albóndigas. 2) Hornear ~20 min. 3) Asar la calabaza. 4) Sumar tomate y huevo duro a la calabaza tibia. 5) Servir juntos.',
        'Adaptación de grilla + hamburguesa de lentejas'],
      ['Jueves', 'Almuerzo', 'Milanesas de pollo con avena y semillas + croquetas de verdura',
        '500 g pechuga fileteada; 2 huevos; 80 g avena molida; 30 g semillas. Croquetas: 2 zucchini; 1 zanahoria; 1 huevo; 50 g avena; ajo en polvo/pimentón.',
        '1) Pasar el pollo por huevo y luego avena + semillas; hornear hasta dorar y cocinar por completo. 2) Rallar zucchini y zanahoria, escurrir, mezclar con huevo, avena y condimentos. 3) Formar croquetas y hornear 20–25 min.',
        'Grilla · MENÚ 4 + técnica de empanado del recetario'],
      ['Jueves', 'Cena', 'Wok de caballa con vegetales',
        '2 latas caballa escurrida; 2 zucchini; 1 morrón; 1 cebolla; 2 dientes ajo; 1 cda aceite de lino u oliva / 30 g nueces.',
        '1) Saltear cebolla, morrón, ajo y zucchini con poca agua o sartén antiadherente. 2) Incorporar la caballa al final para calentar sin desarmarla demasiado. 3) Terminar con aceite en crudo o nueces.',
        'Grilla · MENÚ 4'],
      ['Viernes', 'Almuerzo', 'Omelette de espinaca + jardinera',
        '6 huevos; 200 g espinaca; 1 lata grande de jardinera enjuagada; pimienta; opcional queso magro.',
        '1) Enjuagar muy bien la jardinera. 2) Cocinar la espinaca. 3) Hacer un omelette de 3 huevos por persona y sumar espinaca. 4) Servir con la jardinera.',
        'Grilla · MENÚ 5'],
      ['Viernes', 'Cena', 'Tarta de atún y cebolla + ensalada de repollo y zanahoria',
        '1 tapa de tarta sin gluten; 2 latas atún al natural; 2 cebollas; 2 huevos; 2 cditas semillas. Ensalada: 2 zanahorias; 200 g repollo.',
        '1) Cocinar la cebolla con poca agua o sartén antiadherente. 2) Mezclar con atún escurrido y huevos batidos. 3) Colocar sobre 1 sola tapa, espolvorear semillas y hornear hasta cuajar/dorar. 4) Servir con ensalada.',
        'Adaptación práctica de grilla · MENÚ 5'],
      ['Sábado', 'Almuerzo', 'Pollo al limón, romero y mostaza + ensalada',
        '500 g pechuga; 1 limón; mostaza; romero; pimienta. Ensalada: 2 tomates; 2 zanahorias; 150 g hojas verdes; oliva.',
        '1) Marinar el pollo 15–20 min con limón, mostaza y romero. 2) Cocinar a la plancha o al horno. 3) Preparar la ensalada y agregar oliva en crudo.',
        'Grilla · MENÚ 6 / recetario saludable'],
      ['Sábado', 'Cena', 'Puré mixto papa-calabaza + jurel',
        '350 g papa; 350 g calabaza; 2 latas jurel o 400 g pescado; 1 limón; perejil; 1 diente ajo; hojas verdes opcionales.',
        '1) Hervir papa y calabaza y hacer puré. 2) Calentar/cocinar el pescado. 3) Condimentar con limón, perejil y ajo. 4) Sumar ensalada verde si desean.',
        'Grilla · MENÚ 6'],
      ['Domingo', 'Almuerzo', 'Fideos de zucchini con salsa verde',
        '4 zucchini; 300 g acelga/espinaca; 300 ml leche/bebida vegetal; 20 g maicena; 1 diente ajo; 40 g queso rallado opcional; pimienta.',
        '1) Cortar zucchini en tiras tipo fideo y saltear brevemente. 2) Cocinar la acelga/espinaca. 3) Hacer salsa blanca liviana con leche + maicena, incorporar hojas verdes y mixear. 4) Mezclar con los fideos; queso opcional.',
        'Adaptación práctica de grilla · MENÚ 7'],
      ['Domingo', 'Cena', 'Albóndigas de arvejas + puré mixto + champiñones con rúcula',
        '1 taza arvejas cocidas; 1/2 taza arroz cocido; 1 cebolla chica; 1 morrón chico; 1/4 taza harina integral; ajo en polvo/pimentón. Acompañar: 500 g puré papa-calabaza; 300 g champiñones; 100 g rúcula.',
        '1) Mixear arvejas con arroz. 2) Cocinar cebolla y morrón. 3) Integrar con harina y condimentos. 4) Formar bolitas y hornear fuerte ~15 min. 5) Servir con puré mixto y champiñones salteados + rúcula.',
        'Recetario legumbrero + grilla · MENÚ 7'],
      ['Base', 'Desayuno/Merienda', 'Avena con cacao, coco y frutos rojos',
        '8 cdas avena; 4 cdas cacao amargo; 2 cdas coco rallado; 1 taza agua caliente; 1 taza frutos rojos.',
        '1) Mezclar avena, cacao y coco. 2) Hidratar con agua caliente y reposar 3 min. 3) Servir con frutos rojos.',
        'Plan alimentario'],
      ['Base', 'Desayuno/Merienda', 'Bowl de yogur, quinoa pop y fruta',
        '400 g yogur natural; 1 taza quinoa pop; 2 porciones de fruta.',
        '1) Repartir yogur en 2 bowls. 2) Agregar quinoa pop. 3) Completar con fruta cortada.',
        'Plan alimentario'],
      ['Base', 'Desayuno/Merienda', 'Hummus para tostadas',
        '2 tazas garbanzos cocidos; 2 cdas pasta de maní sin azúcar; 1 diente ajo; jugo de 1 limón; 3 cdas aceite de oliva; pimentón/sal.',
        '1) Procesar todos los ingredientes. 2) Agregar aceite lentamente. 3) Ajustar textura con agua si hace falta. 4) Guardar en heladera y usar en tostadas.',
        'Recetario legumbrero'],
      ['Base', 'Desayuno/Merienda', 'Pancakes simples para 2',
        '120 g harina de garbanzo o avena molida; 1 huevo; 180 ml leche/bebida vegetal; canela; 1 cdita polvo de hornear opcional.',
        '1) Mezclar hasta obtener masa fluida. 2) Cocinar porciones pequeñas en sartén antiadherente. 3) Servir con pasta de maní + queso untable y fruta cítrica.',
        'Adaptación práctica a la opción de pancakes del plan'],
    ];

    return List.generate(rows.length, (i) {
      final r = rows[i];
      return <String, Object?>{
        'id': i + 1,
        'day': r[0],
        'meal': r[1],
        'name': r[2],
        'ingredients': r[3],
        'preparation': r[4],
        'origin': r[5],
        'order_index': i,
      };
    });
  }
}

class PrepSeed {
  static List<Map<String, Object?>> build() {
    final List<List<Object>> rows = [
      [1, 'Cocinar lentejas', '350 g secas', 'Medallones, albóndigas y ensalada del lunes', 'Porcionar en 1/2 taza / 6 cdas y freezar'],
      [2, 'Cocinar arroz integral', '250 g secos', 'Ensaladas + albóndigas de arvejas', 'Enfriar 6–12 h en heladera; luego usar o freezar'],
      [3, 'Hervir huevos', '8–10 unidades', 'Ensaladas y comidas rápidas', 'Con cáscara en heladera, 4–5 días'],
      [4, 'Cortar verduras base', 'Cebolla, morrón, zanahoria, repollo', 'Reduce tiempos de wok, ensaladas y medallones', 'Tuppers herméticos / freezer según verdura'],
      [5, 'Asar calabaza y verduras', '1 bandeja grande', 'Martes noche + miércoles noche + bases de puré', 'Heladera 3–4 días o freezer'],
      [6, 'Porcionar pollo', '3 paquetes de 500–600 g', 'Martes, jueves y sábado', 'Condimentar y freezar'],
      [7, 'Porcionar merluza', '2 paquetes de 400–500 g', 'Lunes y miércoles', 'Freezer; descongelar en heladera'],
      [8, 'Preparar hummus', '1 receta', 'Viernes desayuno + extras', 'Heladera en recipiente cerrado'],
      [9, 'Lavar y porcionar frutas', '7 días', 'Facilita cumplir 2 frutas/día', 'Heladera; frutos rojos pueden ir al freezer'],
    ];

    return List.generate(rows.length, (i) {
      final r = rows[i];
      return <String, Object?>{
        'id': i + 1,
        'order_index': r[0],
        'task': r[1] as String,
        'quantity': r[2] as String,
        'purpose': r[3] as String,
        'storage': r[4] as String,
        'status': 'pendiente',
      };
    });
  }
}

class PlanNoteSeed {
  static List<Map<String, Object?>> build() {
    final List<List<String>> rows = [
      ['Frutas y verduras', 'Objetivo de aumentar frutas/verduras; al menos 2 frutas y 2 verduras de base, con 1 cítrica diaria.', 'Se incluyeron 14 cítricos y fruta extra para 2 personas.', 'PLAN ALIMENTARIO GUIDO C.'],
      ['Proteínas', 'Fuente proteica en cada comida; pescados al menos 2 veces/semana.', 'La semana incluye pollo, huevos, merluza, caballa, atún, jurel y legumbres.', 'PLAN ALIMENTARIO GUIDO C.'],
      ['Legumbres', 'Sumarlas progresivamente en medallones, dips, panes, ensaladas y purés.', 'Hay lentejas, garbanzos/hummus y arvejas en varios días.', 'PLAN + RECETARIO LEGUMBRERO'],
      ['Cereales', 'Priorizar integrales y, cuando sea posible, cocinar/enfriar ≥6 h.', 'Arroz integral y avena; meal prep recuerda el enfriado.', 'PLAN ALIMENTARIO GUIDO C.'],
      ['Grasas', 'Frutos secos, semillas y aceites de buena calidad.', 'Se incluyeron nueces, semillas, oliva y opción de lino.', 'PLAN ALIMENTARIO GUIDO C.'],
      ['Ultraprocesados', 'Limitar paquetes, caldos industriales y saborizantes.', 'Las recetas usan especias, limón, hierbas y preparaciones caseras.', 'PLAN ALIMENTARIO GUIDO C.'],
      ['Menús', 'Se tomaron MENÚ 1 a MENÚ 7 para armar una semana.', 'Almuerzos y cenas siguen esa grilla; donde faltaba receta se marcó como adaptación práctica.', 'GRILLA DE MENÚ ANTIINFLAMATORIO GUIDO C.'],
    ];

    return List.generate(rows.length, (i) {
      final r = rows[i];
      return <String, Object?>{
        'id': i + 1,
        'topic': r[0],
        'respected': r[1],
        'applied': r[2],
        'source': r[3],
        'order_index': i,
      };
    });
  }
}

class MetaSeed {
  static List<Map<String, Object?>> build() => [
        {'key': 'people_count', 'value': '2'},
        {'key': 'days_count', 'value': '7'},
        {'key': 'plan_title', 'value': 'PLAN SEMANAL · 2 PERSONAS'},
        {'key': 'plan_subtitle', 'value': 'Basado en tu plan alimentario y en los MENÚ 1–7 de la grilla.'},
        {'key': 'plan_rule', 'value': '1 fruta cítrica por persona + 1 fruta extra por persona. Agua como hidratación principal. Separar mate/té/café al menos 1 hora de las comidas principales.'},
        {'key': 'shopping_note', 'value': 'Las cantidades son una estimación práctica para cubrir el menú de 7 días. Condimentos, aceite y productos de despensa pueden sobrar para semanas siguientes.'},
      ];
}
