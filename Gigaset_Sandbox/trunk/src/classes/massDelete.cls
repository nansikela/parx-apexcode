global class massDelete {
    
    webService static void init(list<String> ObjId) {
        Database.delete(ObjId);
    }

}