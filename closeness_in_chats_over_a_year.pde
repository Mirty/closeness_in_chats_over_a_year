import java.util.Calendar;

String CONTACT_NAME = "your contact name"; 
int YEAR = 2018;
String ME = "Marta";

color bgColor, textColor, myColor, otherColor;
JSONArray JSONchat_list;
JSONArray messages;
String JSONfile_name;
HashMap <Integer, IntDict> day_by_day;
Calendar calendar;
int centerX, centerY;
int BORDER = 10;
int MAX_ELLIPSE_SIZE = 20;
String text;

void setup () {
  // grafica
  size (1390, 800, P2D); 
  centerX = width/2;
  centerY = height/2 + 30;
  pixelDensity (2);
  PFont myFont = createFont("Staatliches-Regular", 32);
  textFont(myFont);
  bgColor = color (#eeeeee);
  textColor = color (#222831);
  myColor = color (#222831);
  otherColor = color (#222831);
  strokeWeight(2);
  surface.setTitle ("closness in chats over a year");
  text = "me and " + CONTACT_NAME + " during " + YEAR;

  calendar = Calendar.getInstance();

  // carico i dati
  loadData ();
  
  // popolo la hashmap: giorno per giorno con la somma dei messaggi inviati e ricevuti
  day_by_day = setElements ();
}

void draw () {
  background (bgColor);
  fill(textColor);
  text(text, 950, 70); 
  drawLines ();
  noLoop ();
}

void drawLines () {
  // funzione per il disegno delle linee e delle ellissi
  
  int number_of_days = 366;
  // stabilisco di quanto distanziare i punti orizzonalmente
  float increment = (width - BORDER*2) / float(number_of_days);
  // trovo la posizione in x di partenza
  float x = centerX - ((number_of_days/2) * increment);
  // trovo la posizione in y di partenza
  int y = centerY;
  // stabilisco di quanto scalare i punti in verticale
  int scale = 4;
  
  Point [] points = new Point [4]; // per tenere traccia dei miei ultimi punti
  Point [] otherPoints = new Point [4]; // per tenere traccia degli ultimi punti dell'altro contatto
  
  int max_msgs_per_day = 80; // massimo numero di messaggi che suppongo ci siamo scambiati in un giorno (a testa)
  boolean prima_iterazione = true;
  IntDict day;
  int n_mine = 0, n_others = 0;
  
  
  // scorro tutti i giorni dell'anno
  for (int i = 0; i < number_of_days; i++) { // 366 perché considero gli anni bisestili
    
    day = day_by_day.get (i);
    if (day == null) {
      n_mine = 0;
      n_others = 0;
    }
    if (day != null) { // se ci siamo scambiati messaggi...
      n_mine = day.get(ME);
      n_others = day.get(CONTACT_NAME);
    }
    
    
    // disegno il primo punto
    y = centerY - (max_msgs_per_day - n_mine) * scale;
    points [3] = new Point (x, y);
    if (prima_iterazione) { // per evitare che il primo punto sia inizializzato male
      points [0] = points [3];
      points [1] = points [3];
      points [2] = points [3];
    }
    stroke (myColor);
    curve (points[0].x, points[0].y, points[1].x, points[1].y, points[2].x, points[2].y, points[3].x, points[3].y);
    noStroke ();
    // aggiorno la posizione dei punti
    points[0] = points[1];
    points[1] = points[2];
    points[2] = points[3];
    
    
    // disegno il secondo punto
    y = centerY + (max_msgs_per_day - n_others) * scale; 
    otherPoints [3] = new Point (x, y);
    if (prima_iterazione) { // per evitare che il primo punto sia inizializzato male
      otherPoints [0] = otherPoints [3];
      otherPoints [1] = otherPoints [3];
      otherPoints [2] = otherPoints [3];
      prima_iterazione = false;
    }
    stroke (otherColor);
    curve (otherPoints[0].x, otherPoints[0].y, otherPoints[1].x, otherPoints[1].y, otherPoints[2].x, otherPoints[2].y, otherPoints[3].x, otherPoints[3].y);
    noStroke ();    
    // aggiorno la posizione dei punti
    otherPoints[0] = otherPoints[1];
    otherPoints[1] = otherPoints[2];
    otherPoints[2] = otherPoints[3];
    
    // disegno l'ellisse al centro se ci siamo mandati lo stesso numero di messaggi
    if (n_mine - n_others < 5) {
      fill (otherColor, (n_others / float(max_msgs_per_day)) * 255);
      ellipse (x, centerY, 2 + MAX_ELLIPSE_SIZE * (n_others / float(max_msgs_per_day)), 2 + MAX_ELLIPSE_SIZE * (n_others / float(max_msgs_per_day)));
      noFill ();  
    }
    
    x += increment;
  }
}


HashMap <Integer, IntDict> setElements () {
  // funzione che giorno per giorno conta quanti messaggi sono stati inviati rispettivamente
  
  HashMap <Integer, IntDict> day_by_day = new  HashMap <Integer, IntDict> ();
  int dayOfYear;
  JSONObject msg;

  // vado a scorrere messages
  for (int i = 0; i < messages.size (); i ++) {
    msg = messages.getJSONObject (i);
    // ottengo la data
    String date = msg.getString("date").substring(0, 10); 
    // vado a prendere il giorno e il mese
    dayOfYear = getDayOfTheYear (date);
    
    // se non esiste già la chiave di questo giorno nella hashmap la creo
    if (day_by_day.get (dayOfYear) == null) {
      day_by_day.put (dayOfYear, new IntDict ());
      day_by_day.get (dayOfYear).set(ME, 0);
      day_by_day.get (dayOfYear).set(CONTACT_NAME, 0);
    }
    
    // ottengo il mittente di questo messaggio e incremento la conta
    String mittente = msg.getString ("from");
    if (mittente != null) { // nei messaggi phone call non c'è il campo from e quindi mittente = null
      if (mittente.equals(ME)) {
        day_by_day.get (dayOfYear).increment(ME);
      }
      else day_by_day.get (dayOfYear).increment(CONTACT_NAME);
    }
  }
  return day_by_day;
}


int getDayOfTheYear (String date) {
  // funzione che, presa una data, restituisce il corrispondente n-esimo giorno dell'anno
  int day = int(date.substring(8, 10));
  int month = int (date.substring(5, 7));

  // vado a calcolarne il giorno dell'anno
  calendar.set(YEAR, month-1, day);
  return calendar.get(Calendar.DAY_OF_YEAR);
}


void loadData () {
  // funzione che carica i dati della chat in messages
  JSONfile_name = CONTACT_NAME + "_" + YEAR +".json";
  File f = new File(dataPath(JSONfile_name));

  if (f.exists()) {
    // controllo se il file esiste, altrimenti lo creo e carico i dati
    println (JSONfile_name + " esiste e ne carico i dati...");
    messages = loadJSONArray(JSONfile_name);
  } else {
    println (JSONfile_name + " non esiste ancora. Ottengo i dati...");
    JSONfile_name = "modified.json";
    // carico il file json
    JSONchat_list = loadJSONObject(JSONfile_name).getJSONObject("chats").getJSONArray("list");
    // carico la chat desiderata come JSONArray
    messages = loadChat ();
    println ("Ho caricato " + messages.size () + " messaggi della chat " + CONTACT_NAME);
    // carico i messaggi dell'anno scelto
    messages = loadYear ();
    println ("Ho caricato " + messages.size () + " messaggi dell'anno " + YEAR);
    // salvo nel file JSON
    JSONfile_name = CONTACT_NAME + "_" + YEAR +".json";
    saveJSONArray(messages, "data/" + JSONfile_name);
    println ("Ho salvato l'oggetto JSON nel file " + JSONfile_name);
  }
}

JSONArray loadChat () {
  // funzione che carica la chat della persona scelta
  JSONObject chat = new JSONObject ();
  JSONArray messages = new JSONArray ();
  String chat_name;
  for (int i = 0; i < JSONchat_list.size (); i++) {
    chat = JSONchat_list.getJSONObject (i);
    chat_name = chat.getString ("name");
    if (chat_name!= null && chat_name.equals(CONTACT_NAME)) {
      messages = chat.getJSONArray("messages");
      return messages;
    }
  }
  return messages;
}


JSONArray loadYear () {
  // funzione che carica la chat dell'anno scelto
  JSONObject msg = new JSONObject ();
  JSONArray msgs = new JSONArray ();
  int year = 0;
  for (int i = 0; i < messages.size (); i++) {
    msg = messages.getJSONObject (i);
    year = int(msg.getString ("date").substring(0, 4));
    if (year == YEAR) {
      msgs.setJSONObject (msgs.size(), msg);
    }
  }
  return msgs;
}
