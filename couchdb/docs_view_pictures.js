{
  "views" : {
    "byUserrefToObj" : {
      "map" : "function(doc){if(doc.type==='picture'){emit(doc.user_ref, doc)}}"
    },
    "byUUIDToObj" : {
      "map" : "function(doc){if(doc.type==='picture'){emit(doc.pictureUUID, doc)}}"
    }
  }
}