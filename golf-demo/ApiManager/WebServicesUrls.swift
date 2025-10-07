//
//  WebServicesUrls.swift
//  skai-fitness
//
//  Created by iMac on 20/12/24.
//

import Foundation

let serverUrl = "http://157.245.106.111:3322/api/v1/"
//let socketServerUrl = "http://dev.iroidsolutions.com:3101"
let socketServerUrl = "http://157.245.106.111:3322/"

// MARK: - LogIn -
let loginURL = serverUrl + "auth/login"
let signUpURL = serverUrl + "auth/signup"
let otpVerifyURL = serverUrl + "otp/verify"


// MARK: - Onboarding -
let userDetailsURL = serverUrl + "user/details"

// MARK: - Home Screen -
let categoriesURL = serverUrl + "main/category"     // Get Categories List
let subCategoriesURL = serverUrl + "category"     // Get Categories List
let productsURL = serverUrl + "customer/home"     // Get Products
let productListURL = serverUrl + "customer/get-product-list"     // Get Products List(Discover what you love)
let professionalCategoryURL = serverUrl + "professional/category"     // Get Professional Category
let professionalSubCategoryURL = serverUrl + "professional/sub-category"     // Get Professional Sub Category
let colourUrl = serverUrl + "color/dropdown"       // Get Colour list

// MARK: - Store Card Screen -
let likeDislikeUrl = serverUrl + "favorites"        // Set Like Dislike card

// MARK: - Search Screen -
let searchUrl = serverUrl + "customer/search-suggestions?search="      // Search item
let searchHistoryUrl = serverUrl + "customer/search-history"      // Search History Url
let getProductListyUrl = serverUrl + "customer/get-product-list"      // Get Product List
let deleteHistoryUrl = serverUrl + "customer/search-history-delete"          // Delete History Url
let notificationUrl = serverUrl + "notification"                // Get Notification
let deleteNotificationUrl = serverUrl + "notifications/delete"  // delete Notification
let markAsSeenNotification = serverUrl + "notification/mark-as-seen"    // mark-as-seen Notification
let sellerDetailsUrl = serverUrl + "customer/owner-profile/"           // seller Details 

// MARK: - Chat Screen -
let getChatListUrl = serverUrl + "chat-list"        // Get Chat List
let getHistoryUrl = serverUrl + "chat-message-list"        // Get Chat Hostory
let sendImageUrl = serverUrl + "send-media"        // Image Send

// MARK: - Product Detail -
let productDetailUrl = serverUrl + "customer/product/"       // Get Product Detail
let addToCartUrl = serverUrl + "customer/product/AddtoCart"       // Get Product Detail

// MARK: - Profile Screen -
let profileUrl = serverUrl + "customer/update"       // Update Profile
let addAddressUrl = serverUrl + "customer/delivery-address"       // Add Delivey Address, Get Addtess
let deleteAddressUrl = serverUrl + "customer/delivery-address/delete/"       // Delete Address
let editAddressUrl = serverUrl + "customer/delivery-address/edit/"       // Edit Address
let changeNotificationUrl = serverUrl + "customer/push/notification/setting"       // Update push notification
let sendVerificationOTPUrl = serverUrl + "customer/number/change/send-otp"       // Change Mobile number OTP
let verifyOTPUrl = serverUrl + "customer/number/change/verify-otp"       // Verify Mobile number OTP
let filterfavoriteUrl = serverUrl + "favorite/filter/categories"
let favoriteUrl = serverUrl + "favorites"       // Get Fav Store
let myOrderUrl = serverUrl + "customer/myorders"       // Get My Orders
let logoutUser = serverUrl + "auth/logout"        // logout Account
let getUserId = serverUrl + "areas"           // get AreaId
let termsAndPolicyUrl = serverUrl + "terms-and-policies"            //get Terms And Policy

// MARK: - Explore -
let exploreUrl = serverUrl + "customer/explore"
let getProjectDetails = serverUrl + "customer/project/detail/"

// MARK: - Cart -
let getCartProductsUrl = serverUrl + "customer/product/cart/get"            // Verify Mobile number OTP
let deleteCartProduct = serverUrl + "customer/product/deleteCartItem/"      // Delete Cart Product
let getCartUrl = serverUrl + "customer/product/cart/"                       // Delete Cart Product

// MARK: - Seller Profile -
let gerFaqsUrl = serverUrl + "customer/store/faq/"                         // Get FAQ
let gerStoryUrl = serverUrl + "customer/user/story/"                       // Get Story URL
let gerDetailUrl = serverUrl + "customer/store/details/"                   // Get Detail
let getSellerProductUrl = serverUrl + "customer/seller-product"            // Get Seller products
let getProfessionalPortFolioUrl = serverUrl + "customer/professional-portfolio"     // Get professional products
let getProfessionalPortFolio6Url = serverUrl + "professional-portfolio-combined"
let setRecommendationUrl = serverUrl + "customer/recommendation"           // Get Customer recommendation
let getProfessionalTitleUrl = serverUrl + "professional/product/titles"    // Get Professional Title
let getStoreCategoryUrl = serverUrl + "customer/main/category/data-wise"   // Get Store Profile Main Category
let getStoreSubCategoryUrl = serverUrl + "customer/category/data-wise"     // Get Store Profile Sub Category

// MARK: - Delete Cart -
let orderUrl = serverUrl + "customer/order/create"      // Create Order

// MARK: - Delete Account -
let deleteAccountUrl = serverUrl + "delete/account"

// MARK: - ChatBot -
let chatBotUrl = "https://chatbot.iroidsolutions.in/api/external-access/Cmtl7F5kL5UW"
