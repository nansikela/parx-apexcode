trigger beforeInsertMonitorEntityFeeds on FeedItem (before insert) {
    for (FeedItem f: trigger.new)
    {
        if ( f.Type=='LinkPost' && f.Body != null && f.Body.StartsWith('Just installed Chatter')) {
           f.Body.addError('Unwanted FeedItem');                      
        }
    } 
}