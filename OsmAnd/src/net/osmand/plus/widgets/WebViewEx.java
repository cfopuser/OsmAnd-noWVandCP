package net.osmand.plus.widgets;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.Configuration;
import android.os.Build;
import android.util.AttributeSet;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import net.osmand.PlatformUtil;
import net.osmand.plus.OsmandApplication;
import net.osmand.plus.R;

import org.apache.commons.logging.Log;

import java.util.Locale;
import java.util.Map;

public class WebViewEx extends WebView {

	private static final Log LOG = PlatformUtil.getLog(WebViewEx.class);

	public WebViewEx(Context context) {
		super(context);
		initKioskWebView(context);
	}

	public WebViewEx(Context context, AttributeSet attrs) {
		super(context, attrs);
		initKioskWebView(context);
	}

	public WebViewEx(Context context, AttributeSet attrs, int defStyleAttr) {
		super(context, attrs, defStyleAttr);
		initKioskWebView(context);
	}

	public WebViewEx(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
		super(context, attrs, defStyleAttr, defStyleRes);
		initKioskWebView(context);
	}

	@SuppressLint("SetJavaScriptEnabled")
	private void initKioskWebView(Context ctx) {
		fixWebViewResetsLocaleToUserDefault(ctx);
		WebSettings settings = getSettings();
		settings.setBlockNetworkLoads(true);
		settings.setGeolocationEnabled(false);
		settings.setSupportMultipleWindows(false);
		settings.setAllowFileAccess(true);
		settings.setAllowContentAccess(true);
		super.setWebViewClient(new KioskWebViewClientWrapper(null));
	}

	public void fixWebViewResetsLocaleToUserDefault(Context ctx) {
		// issue details: https://issuetracker.google.com/issues/37113860
		// also see: https://gist.github.com/amake/0ac7724681ac1c178c6f95a5b09f03ce
		OsmandApplication app = (OsmandApplication) ctx.getApplicationContext();
		app.getLocaleHelper().checkPreferredLocale();
		ctx.getResources().updateConfiguration(
				new Configuration(app.getResources().getConfiguration()),
				ctx.getResources().getDisplayMetrics());
	}

	public static boolean isRemoteUrl(@Nullable String url) {
		if (url == null) {
			return false;
		}
		String lower = url.trim().toLowerCase(Locale.US);
		return lower.startsWith("http://") || lower.startsWith("https://") || lower.startsWith("//");
	}

	@Override
	public void loadUrl(@NonNull String url) {
		if (isRemoteUrl(url)) {
			LOG.warn("Blocked remote URL load in kiosk mode: " + url);
			super.loadUrl("about:blank");
			return;
		}
		super.loadUrl(url);
	}

	@Override
	public void loadUrl(@NonNull String url, @NonNull Map<String, String> additionalHttpHeaders) {
		if (isRemoteUrl(url)) {
			LOG.warn("Blocked remote URL load with headers in kiosk mode: " + url);
			super.loadUrl("about:blank", additionalHttpHeaders);
			return;
		}
		super.loadUrl(url, additionalHttpHeaders);
	}

	@Override
	public void postUrl(@NonNull String url, @NonNull byte[] postData) {
		if (isRemoteUrl(url)) {
			LOG.warn("Blocked remote POST URL in kiosk mode: " + url);
			return;
		}
		super.postUrl(url, postData);
	}

	@Override
	public void loadDataWithBaseURL(@Nullable String baseUrl, @NonNull String data,
			@Nullable String mimeType, @Nullable String encoding, @Nullable String historyUrl) {
		if (isRemoteUrl(baseUrl)) {
			baseUrl = null;
		}
		super.loadDataWithBaseURL(baseUrl, data, mimeType, encoding, historyUrl);
	}

	@Override
	public void setWebViewClient(@Nullable WebViewClient client) {
		super.setWebViewClient(new KioskWebViewClientWrapper(client));
	}

	public static class KioskWebViewClientWrapper extends WebViewClient {
		private final WebViewClient delegate;

		public KioskWebViewClientWrapper(@Nullable WebViewClient delegate) {
			this.delegate = delegate;
		}

		@Override
		public boolean shouldOverrideUrlLoading(WebView view, String url) {
			if (isRemoteUrl(url)) {
				Context ctx = view != null ? view.getContext() : null;
				if (ctx != null) {
					OsmandApplication app = (OsmandApplication) ctx.getApplicationContext();
					app.showToastMessage(R.string.web_access_disabled);
				}
				return true;
			}
			if (delegate != null) {
				return delegate.shouldOverrideUrlLoading(view, url);
			}
			return super.shouldOverrideUrlLoading(view, url);
		}

		@RequiresApi(api = Build.VERSION_CODES.N)
		@Override
		public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
			if (request != null && request.getUrl() != null) {
				String scheme = request.getUrl().getScheme();
				if (scheme != null && (scheme.equalsIgnoreCase("http") || scheme.equalsIgnoreCase("https"))) {
					Context ctx = view != null ? view.getContext() : null;
					if (ctx != null) {
						OsmandApplication app = (OsmandApplication) ctx.getApplicationContext();
						app.showToastMessage(R.string.web_access_disabled);
					}
					return true;
				}
			}
			if (delegate != null) {
				return delegate.shouldOverrideUrlLoading(view, request);
			}
			return super.shouldOverrideUrlLoading(view, request);
		}
	}
}
