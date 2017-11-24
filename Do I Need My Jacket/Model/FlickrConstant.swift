//
//  FlickrConstant.swift
//  Do I Need My Jacket
//
//  Created by Duy Le on 11/20/17.
//  Copyright © 2017 Duy Le. All rights reserved.
//

class FlickrConstant {
    static let APIBaseUrl = "https://api.flickr.com/services/rest/?"
    struct API {
        static let key = "bf4c23ee659157055dfdbf4f5bb322f8"
    }
    struct Method {
        static let SearchImage = "flickr.photos.search"
    }
    struct RequestParameter {
        static let Method = "method"
        static let ApiKey = "api_key"
        static let Format = "format"
        static let Extra = "extras"
        static let NoJSONCallback = "nojsoncallback"
        static let perPage = "per_page"
        static let Page = "page"
        static let GroupId = "group_id"
        static let SafeSearch = "safe_search"
    }
    struct RespondParameter {
        static let REST = "rest"
        static let Format = "json"
        static let Extra = "url_m"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
    }
}
