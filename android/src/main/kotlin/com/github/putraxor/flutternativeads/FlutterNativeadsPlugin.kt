package com.github.putraxor.flutternativeads

import android.app.Activity
import android.app.Dialog
import android.util.Log
import android.view.Window
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.PluginRegistry.Registrar
import com.google.android.gms.ads.AdListener
import com.google.android.gms.ads.AdLoader
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.MobileAds
import android.app.AlertDialog
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.widget.EditText
import android.view.View
import android.view.LayoutInflater
import android.widget.TextView
import com.google.android.gms.ads.formats.*


class FlutterNativeadsPlugin() : MethodCallHandler {

    private var admobId = "ca-app-pub-3940256099942544~3347511713"
    private var adUnitId = "ca-app-pub-3940256099942544/6300978111"
    private var testDeviceId: String? = "37B699B4E6C1FC134B9A272DD9B71BD0"

    private val tags = "flutter_nativeads"
    private var activity: Activity? = null

    private var installAd: NativeAppInstallAd? = null
    private var contentAd: NativeContentAd? = null

    /**
     * Plugin Consctructor
     */
    constructor(activity: Activity) : this() {
        this.activity = activity
    }


    /**
     * Plugin registrant
     */
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val method = MethodChannel(registrar.messenger(), "flutter_nativeads/method_channel")
            method.setMethodCallHandler(FlutterNativeadsPlugin(registrar.activity()))
        }
    }

    /**
     * On plugin method call
     */
    override fun onMethodCall(call: MethodCall, result: Result) {
        when {
            call.method == "setConfiguration" -> {
                setConfiguration(
                        admobId = call.argument("admobId"),
                        adUnitId = call.argument("adUnitId"),
                        testDeviceId = call.argument("testDeviceId")
                )
                result.success("AdMob set to id:$admobId unit:$adUnitId testDevice: $testDeviceId")
            }
            call.method == "initializeAd" -> {
                initializeAd()
                result.success("MobileAds has been initialized")
            }
            call.method == "clickAd" -> {
                val id: Int = call.argument("id")
                clickAd(id)
                result.success("clickAd performed for ad's id $id")
            }
            call.method == "loadAds" -> {
                val type: String = call.argument("type")
                loadAds(result, type)
            }
            call.method == "startAdImpression" -> {
                val id: Int = call.argument("id")
                startAdImpression(id)
                result.success("startAdImpression performed for ad's id $id")
            }
            call.method == "destroyAd" -> {
                val id: Int = call.argument("id")
                destroyAd(id)
                result.success("destroyAd performed for ad's id $id")
            }
            else -> result.notImplemented()
        }
    }

    /**
     * Perform destroy ads
     */
    private fun destroyAd(id: Int) {
        installAd?.let {
            if (it.hashCode() == id) {
                it.destroy()
            }
        }
        contentAd?.let {
            if (it.hashCode() == id) {
                it.destroy()
            }
        }
    }

    /**
     * Perform start impression
     */
    private fun startAdImpression(id: Int) {
        installAd?.let {
            if (it.hashCode() == id) {
                it.recordImpression(activity?.intent?.extras)
            }
        }
        contentAd?.let {
            if (it.hashCode() == id) {
                it.recordImpression(activity?.intent?.extras)
            }
        }
    }

    /**
     * Perform click on ads
     */
    private fun clickAd(id: Int) {
        installAd?.let {
            if (it.hashCode() == id) {
                shoAdDialog(it)
                //it.performClick(activity?.intent?.extras)
            }
        }
        contentAd?.let {
            if (it.hashCode() == id) {
                it.performClick(activity?.intent?.extras)
            }
        }
    }


    private fun shoAdDialog(ad: NativeAppInstallAd) {
        activity?.let {
            val dialogBuilder = AlertDialog.Builder(activity)
            val inflater = it.layoutInflater
            val dialogView = inflater.inflate(R.layout.native_app_install, null)
            dialogBuilder.setView(dialogView)
            val adView = dialogView.findViewById<NativeAppInstallAdView>(R.id.ad_view)
            adView.headlineView = adView.findViewById<TextView>(R.id.ad_headline).apply {
                text = ad.headline
            }
            adView.bodyView = adView.findViewById<TextView>(R.id.ad_body).apply {
                text = ad.body
            }
            adView.callToActionView = adView.findViewById<TextView>(R.id.ad_cta).apply {
                text = ad.callToAction
            }
            adView.setNativeAd(ad)
            val adDialog = dialogBuilder.create()
            adDialog.window.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
            adDialog.show()
        }
    }

    /**
     * Set ad id configuration
     */
    private fun setConfiguration(admobId: String, adUnitId: String, testDeviceId: String) {
        this.admobId = admobId
        this.adUnitId = adUnitId
        this.testDeviceId = testDeviceId
    }

    /**
     * Initialize admob
     */
    private fun initializeAd() {
        MobileAds.initialize(activity, admobId)
    }

    /**
     * Method to load ads with limit max 5
     */
    private fun loadAds(result: Result, adType: String) {
        destroyAds()

        val builder = AdLoader.Builder(activity, adUnitId)

        when (adType) {
            "NativeAppInstallAd" -> builder.forAppInstallAd { ad: NativeAppInstallAd ->
                installAd = ad
                val data = mapOf(
                        "id" to "${ad.hashCode()}",
                        "headline" to ad.headline.toString(),
                        "body" to ad.body.toString(),
                        "cta" to ad.callToAction.toString(),
                        "icon" to ad.icon.uri.toString(),
                        "price" to ad.price.toString(),
                        "rating" to ad.starRating.toString()
                )
                Log.d(tags, "Loaded NativeAppInstallAd $data")
                result.success(data)
            }
            else -> builder.forContentAd { ad: NativeContentAd ->
                contentAd = ad
                val data = mapOf(
                        "id" to "${ad.hashCode()}",
                        "headline" to ad.headline.toString(),
                        "cta" to ad.callToAction.toString(),
                        "logo" to "${ad.logo?.uri}",
                        "advertiser" to ad.advertiser.toString(),
                        "body" to ad.body.toString()
                )
                Log.d(tags, "Loaded NativeContentAd $data")
                result.success(data)
            }
        }

        val adLoader = builder.withAdListener(object : AdListener() {
            override fun onAdFailedToLoad(errorCode: Int) {
                result.error("AdFailedToLoad", "Ad failed to load, error code $errorCode", errorCode)
                Log.e(tags, "Ad failed to load, error code $errorCode")
            }
        }).build()
        val adRequest = AdRequest.Builder().addTestDevice(testDeviceId).build()
        adLoader.loadAd(adRequest)
        //adLoader.loadAds(adRequest, 3) //load multiple ads
    }

    /**
     * Method to destroy ads
     */
    private fun destroyAds() {
        installAd?.destroy()
        contentAd?.destroy()
    }
}
