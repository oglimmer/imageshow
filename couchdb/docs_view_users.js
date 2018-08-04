{
  "views" : {
    "byEmailToObj" : {
      "map" : "function(doc){if(doc.type==='user'){emit(doc.email.toLowerCase(), doc)}}"
    }
  }
}