package net.osmand.plus.feedback;

import static net.osmand.aidlapi.OsmAndCustomizationConstants.FRAGMENT_RATE_US_ID;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentActivity;

import com.google.android.play.core.review.ReviewInfo;
import com.google.android.play.core.review.ReviewManager;
import com.google.android.play.core.review.ReviewManagerFactory;
import com.google.android.gms.tasks.Task;

import net.osmand.PlatformUtil;
import net.osmand.plus.OsmandApplication;
import net.osmand.plus.Version;
import net.osmand.plus.activities.MapActivity;
import net.osmand.plus.settings.backend.OsmandSettings;

import org.apache.commons.logging.Log;

import java.lang.ref.WeakReference;

public class RateUsHelper {

	private static final Log log = PlatformUtil.getLog(RateUsHelper.class);
	private static final long SIXTY_DAYS = 60 * 24 * 60 * 60 * 1000L;

	private RateUsState rateUsState;

	public RateUsHelper() {
		this.rateUsState = RateUsState.IGNORED;
	}

	public void storeRateResult(@Nullable FragmentActivity activity) {
		storeRateResult(activity, rateUsState);
	}

	private static void storeRateResult(@Nullable FragmentActivity activity, @Nullable RateUsState state) {
		if (state != null && activity != null && !activity.isChangingConfigurations()) {
			OsmandApplication app = (OsmandApplication) activity.getApplication();
			OsmandSettings settings = app.getSettings();
			RateUsState newState = RateUsState.getNewState(app, state);
			settings.RATE_US_STATE.set(newState);
			if (newState != RateUsState.LIKED) {
				settings.NUMBER_OF_APP_STARTS_ON_DISLIKE_MOMENT.set(app.getAppInitializer().getNumberOfStarts());
			}
			settings.LAST_DISPLAY_TIME.set(System.currentTimeMillis());
		}
	}

	public void updateState(@Nullable RateUsState state) {
		this.rateUsState = state;
	}

	public static boolean shouldShowRateDialog(OsmandApplication app) {
		return false;
	}

	public static void showRateDialog(@NonNull MapActivity mapActivity) {
		if (Version.isGooglePlayInstalled(mapActivity.getApp())) {
			showInAppRateDialog(mapActivity);
		} else {
			RateUsBottomSheetDialogFragment.showInstance(mapActivity.getSupportFragmentManager());
		}
	}

	private static void showInAppRateDialog(FragmentActivity activity) {
		ReviewManager reviewManager = ReviewManagerFactory.create(activity);
		WeakReference<FragmentActivity> activityRef = new WeakReference<>(activity);
		Task<ReviewInfo> requestReview = reviewManager.requestReviewFlow();
		requestReview.addOnCompleteListener(task -> {
			if (task.isSuccessful()) {
				FragmentActivity fragmentActivity = activityRef.get();
				if (fragmentActivity != null) {
					showInAppRateDialogInternal(reviewManager, fragmentActivity, task.getResult());
				}
			} else {
				log.error(task.getException());
			}
		});
	}

	private static void showInAppRateDialogInternal(ReviewManager reviewManager, FragmentActivity activity, ReviewInfo reviewInfo) {
		Task<Void> reviewFlow = reviewManager.launchReviewFlow(activity, reviewInfo);
		WeakReference<FragmentActivity> activityRef = new WeakReference<>(activity);
		reviewFlow.addOnCompleteListener(task -> {
			if (task.isSuccessful()) {
				FragmentActivity fragmentActivity = activityRef.get();
				if (fragmentActivity != null) {
					storeRateResult(fragmentActivity, RateUsState.IGNORED);
				}
			} else {
				log.error(task.getException());
			}
		});
	}
}