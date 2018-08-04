{
  "views" : {
    "byUserrefToObj" : {
      "map" : "function(doc){if(doc.type==='picturegroup'){emit(doc.user_ref, doc)}}"
    },
    "byUserrefToName" : {
      "map" : "function(doc){if(doc.type==='picturegroup'){emit(doc.user_ref, {_id: doc._id, name: doc.name})}}"
    }
  }
}