//
//  DataModels.swift
//  Sahel
//
//  Created by Octal on 07/11/17.
//  Copyright © 2017 Octal. All rights reserved.
//

import Foundation
import UIKit

struct Location
{
    static var userLat = Double()
    static var userLong = Double()
}

struct AppLanguages {
    static let english : String = "en"
    static let arabic : String = "ar"
}


class UserData: NSObject {
    
    class var sharedInstance: UserData {
        struct Static {
            static let instance: UserData = UserData()
        }
        return Static.instance
    }
    
    var mobile_number       : String = ""
    var modified            : String = ""
    var remember_token      : String = ""
    var longitude           : String = ""
    var latitude            : String = ""
    var is_mobileverify     : String = ""
    var user_id             : String = ""
    var img                 : String = ""
    var first_name          : String = ""
    var is_notification     : String = ""
    var fb_id               : String = ""
    var last_name           : String = ""
    var email               : String = ""
    var role_id             : String = ""
    var country_code        : String = ""
    var cart_id             : String = ""
    var cart_quantity       : String = ""
    
    var address_name        : String = ""
    var address_longitude   : String = ""
    var address_latitude    : String = ""
    var address             : String = ""
    var landmark            : String = ""
    var full_address        : String = ""
    var address_id          : String = ""
    var user_name           : String = ""
    var user_mobile         : String = ""
    var zip_code            : String = ""
    var delivery_address_type : String = ""
}


class NewRequestData: NSObject {
    class var sharedInstance: NewRequestData {
        struct Shared {
            static let instance: NewRequestData = NewRequestData()
        }
        return Shared.instance
    }
    
    func clearInstance() {
        NewRequestData.sharedInstance.service_date = ""
        NewRequestData.sharedInstance.service_time = ""
        NewRequestData.sharedInstance.location_latitude = ""
        NewRequestData.sharedInstance.location_longitude = ""
        NewRequestData.sharedInstance.location_name = ""
        NewRequestData.sharedInstance.comment = ""
        NewRequestData.sharedInstance.promocode = ""
        NewRequestData.sharedInstance.remind_me = ""
        NewRequestData.sharedInstance.language = ""
        NewRequestData.sharedInstance.arrMedia.removeAll()
        NewRequestData.sharedInstance.selectedService = 0;
    }
    
    var isFutureRequest     : String = ""
    var provider_id         : String = ""
    var service_type_id     : String = ""
    var service_date        : String = ""
    var service_time        : String = ""
    var location_latitude   : String = ""
    var location_longitude  : String = ""
    var location_name       : String = ""
    var comment             : String = ""
    var promocode           : String = ""
    var remind_me           : String = ""
    var language            : String = ""
    var user_id             : String = ""
    var serviceTypeName     : String = ""
    var serviceTypeImage    : String = ""
    
    var arrMedia            = Array<MediaDetails>()
    //  "description":"Test Descriptions",
    
    
    // To show on AddNewRequest Screen for change service type option
    var selectedService     : Int = 0
}

struct MediaDetails {
    var mData = NSData()
    var mImage = UIImage()
    var contentType = String()
    var mURL = URL.init(string: "")
    
    // For request details
    var imgURL = URL.init(string: "")
}

struct ProductCategory {
    var id              = String()
    var category_name   = String()
    var img             = String()
    var subcategories   = Array<ProductCategory>()
    var strSubCategories = String()
}

struct ProductsInCategories {
    var min_price   = String()
    var Brands_list = Array<BrandDetails>()
    var Brands      = Array<BrandDetails>()
    var max_price   = String()
}

struct BrandDetails {
    var brand_name      = String()
    var total_products  = String()
    var brand_id        = String()
    var brand_logo      = String()
    var Products        =  Array<ProductsData>()
}

struct ProductsData {
    var quantity            = String()
    var min_quantity        = String()
    var product_name        = String()
    var is_wishlist         = String()
    var product_description = String()
    var avg_price           = String()
    var weight              = String()
    var price               = String()
    var product_id          = String()
    var weight_in           = String()
    var is_offer            = String()
    var offer_price         = String()
    var product_image       = String()
    var avg_rating          = String()
    var offer_expires_on    = String()
    var out_of_stock        : String = "0"
    var review_submited     = String()
    
    var brand_name          = String()
    var brand_logo          = String()
    var ProductImage        = Array<String>()
    
    var wishlist_id         = String()
    
    var cart_qyantity       = String()
    var is_already_added_to_cart = String()
    
    // OrderDetails
    var category            = [ProductCategory]()
}

struct FilterData {
    var brand_iDs       = Array<String>()
    var min_Price       = String()
    var max_Price       = String()
    var star_Rating     = String()
}

struct CartData {
    var product_id       = Array<String>()
    var quantity       = String()
    var product_price       = String()
    var product_name     = String()
}

struct NotificationData {
    var id       = String()
    var message  = String()
    var created  = String()
    var user_id  = String()
    var type     = String()
    var send_by  = String()
    var name     = String()
    var is_read  = String()
    var item_id  = String()
}

struct SavedAddressData {
    var address       = String()
    var longitude  = String()
    var id  = String()
    var is_default  = String()
    var zip_code     = String()
    var latitude  = String()
    var name     = String()
}

struct CouponData {
    var coupon_code         = String()
    var discount            = String()
    var id                  = String()
    var discount_type       = String()
    var category_id         = String()
    var category_name       = String()
    var max_use             = String()
    var coupon_description  = String()
    var expires_on          = String()
    var img                 = String()
    var is_used             = String()
}

class DeliveryAddressDetailsData : NSObject {
    var id                  = String()
    var name                = String()
    var phone_number        = String()
    var appartment_no       = String()
    var floor_no            = String()
    var building_name       = String()
    var street_name         = String()
    var additional_details  = String()
    var full_address        = String()
    var address             = String()
    var longitude           = String()
    var latitude            = String()
    var zip_code            = String()
    var delivery_address_type = String()
    var username            = String()
    
    func propertyNames() -> [String] {
        return Mirror(reflecting: self).children.compactMap { $0.label }
    }
}

struct OrderListData {
    var delivery_date           : String = ""
    var order_id                : String = ""
    var order_delivery_status   : String = ""
    var order_status            : String = ""
    var delivery_start_time     : String = ""
    var total_amount            : String = ""
    var is_cancelled            : String = ""
    var total_quantity          : String = ""
    var delivery_end_time       : String = ""
    var payment_mode            : String = ""
    var transaction_id          : String = ""
    var deliver_mobile          : String = ""
    var cancelled_before        : String = "" //
    var deliver_to              : String = ""
    var delivery_charges        : String = ""
    var net_amount              : String = ""
    var delivery_address        : String = ""
    var loyalty_points          : String = ""
    var loyalty_discount        : String = ""
    var coupon_discount         : String = ""
    var order_date              : String = ""
    
    //
    var delivery_latitude       : String = ""
    var delivery_longitude      : String = ""
    
    //
    var is_edited               : String = ""
    var server_time             : String = ""
    var isEdit                  : String = ""
    var is_delivery_boy         : String = ""
}

struct LoyaltyPointsData {
    var order_id        : String = ""
    var img             : String = ""
    var created_at      : String = ""
    var loyalty_points  : String = ""
    var type            : String = ""
    var user_id         : String = ""
    var user_name       : String = ""
    var id              : String = ""
}








