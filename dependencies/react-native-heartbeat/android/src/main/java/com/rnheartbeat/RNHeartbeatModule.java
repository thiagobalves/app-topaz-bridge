package com.rnheartbeat;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.util.Base64;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.module.annotations.ReactModule;

import java.io.ByteArrayOutputStream;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import br.com.topaz.heartbeat.CurrentLocationCallback;
import br.com.topaz.heartbeat.Event;
import br.com.topaz.heartbeat.Heartbeat;
import br.com.topaz.heartbeat.StartCallback;
import br.com.topaz.heartbeat.ofdcamera.capturedoc.CaptureDocActivity;
import br.com.topaz.heartbeat.ofdcamera.facesequence.FaceSequenceActivity;
import br.com.topaz.heartbeat.ofdcamera.ocr.FilesSenderActivity;
import br.com.topaz.heartbeat.ofdcamera.ocr.LivePreviewActivity;
import br.com.topaz.heartbeat.token.Token;
import br.com.topaz.heartbeat.token.TokenResponse;

@ReactModule(name = RNHeartbeatModule.NAME)
public class RNHeartbeatModule extends ReactContextBaseJavaModule implements ActivityEventListener {
    public static final String NAME = "RNHeartbeat";
    public final int SEND_DOC_FACE_AUTHORIZATION_REQUEST = 9001;
    public final int LIVENESS_FACE_AUTHORIATION_REQUEST = 9002;
    public final int LIVE_OCR_REQUEST = 9003;
    public final int SEND_FILES_OCR_REQUEST = 9004;
    private final ReactApplicationContext reactContext;
    private Callback callback;

    public RNHeartbeatModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        reactContext.addActivityEventListener(this);
    }

    @Override
    @NonNull
    public String getName() {
        return NAME;
    }

    @ReactMethod
    public void start(String clientId, final Callback successCallback, final Callback failureCallback) {
        StartCallback startCallback = new StartCallback() {
            @Override
            public void onSuccess(int statusCode) {
                successCallback.invoke(statusCode);
            }

            @Override
            public void onFailure(int statusCode) {
                failureCallback.invoke(statusCode);
            }
        };

        try {
            Heartbeat.start(getReactApplicationContext().getApplicationContext(), clientId, startCallback);
        } catch (Exception e) {
            failureCallback.invoke("Heartbeat.start Error");
        }
    }

    @ReactMethod
    public void sendEvent(ReadableMap parameters, Callback callback) {
        Event event = new Event(getReactApplicationContext().getApplicationContext());

        try {
            Map<String, Object> eventParameters = parameters.toHashMap();
            for (String key : eventParameters.keySet()) {
                event.addParameter(key, eventParameters.get(key).toString());
            }
            event.sendEvent();
            callback.invoke(0, "Heartbeat.sendEvent requested");
        } catch (Exception e) {
            callback.invoke(-1, "An error occurred requesting Heartbeat.sendEvent");
        }
    }

    @ReactMethod
    public void getSyncID(Callback callback) {
        String syncID = Heartbeat.getSyncID(getReactApplicationContext().getApplicationContext());
        callback.invoke(syncID);
    }

    @ReactMethod
    public void getCurrentLocation(ReadableMap params, Callback successCallback, Callback failureCallback) {
        try {
            Map<String, Object> readableParams = params.toHashMap();
            HashMap<String, String> hashMapParams = new HashMap<>();
            for (String key : readableParams.keySet()) {
                hashMapParams.put(key, Objects.requireNonNull(readableParams.get(key)).toString());
            }

            CurrentLocationCallback currentLocationCallback = new CurrentLocationCallback() {
                @Override
                public void onSuccess(String json) {
                    successCallback.invoke(json);
                }

                @Override
                public void onFailure(int statusCode) {
                    failureCallback.invoke(statusCode);
                }
            };

            Heartbeat.getCurrentLocation(getReactApplicationContext().getApplicationContext(), hashMapParams, currentLocationCallback);
        } catch (Exception e) {
            failureCallback.invoke(-1);
        }
    }

    @ReactMethod
    public void requestAuthorization(ReadableMap parameters, final Callback callback) {
        Token token = buildTokenObject(parameters);

        token.requestAuthorization(new Token.RequestAuthorizationCallback() {
            @Override
            public void onSuccess() {
                callback.invoke(0, "Heartbeat.Token.requestAuthorization success");
            }

            @Override
            public void onFailure(final int statusCode) {
                callback.invoke(statusCode, "Heartbeat.Token.requestAuthorization failure");
            }
        });
    }

    @ReactMethod
    public void authorize(String authorizeCode, ReadableMap parameters, final Callback callback) {
        Token token = buildTokenObject(parameters);

        token.authorize(authorizeCode, new Token.AuthorizeCallback() {
            @Override
            public void onSuccess() {
                callback.invoke(0, "Heartbeat.Token.authorize success");
            }

            @Override
            public void onFailure(final int statusCode) {
                callback.invoke(statusCode, "Heartbeat.Token.authorize failure");
            }
        });
    }

    @ReactMethod
    public void getToken(ReadableMap parameters, final Callback callback) {
        Token token = buildTokenObject(parameters);

        token.getToken(new Token.TokenCallback() {
            @Override
            public void onSuccess(final TokenResponse tokenResponse) {
                WritableNativeMap writableNativeMap = new WritableNativeMap();
                writableNativeMap.putInt("duration", tokenResponse.getDuration());
                writableNativeMap.putString("token", tokenResponse.getToken());
                callback.invoke(0, writableNativeMap);
            }

            @Override
            public void onFailure(final int statusCode) {
                callback.invoke(statusCode, "Heartbeat.Token.getToken failure");
            }
        });
    }

    @ReactMethod
    public void dismiss(ReadableMap parameters, final Callback callback) {
        Token token = buildTokenObject(parameters);

        token.dismiss(new Token.DismissCallback() {
            @Override
            public void onSuccess() {
                callback.invoke(0, "Heartbeat.Token.dismiss success");
            }

            @Override
            public void onFailure(final int statusCode) {
                callback.invoke(statusCode, "Heartbeat.Token.dismiss failure");
            }
        });
    }

    @ReactMethod
    public void checkToken(ReadableMap parameters, final Callback callback) {
        Token token = buildTokenObject(parameters);

        token.checkToken(new Token.CheckTokenCallback() {
            @Override
            public void onSuccess() {
                callback.invoke(0, "Heartbeat.Token.checkToken success");
            }

            @Override
            public void onFailure(final int statusCode) {
                callback.invoke(statusCode, "Heartbeat.Token.checkToken failure");
            }
        });
    }

    @ReactMethod
    public void hasSeed(ReadableMap parameters, Callback callback) {
        Token token = buildTokenObject(parameters);

        if (token.hasSeed()) {
            callback.invoke(true, "Heartbeat.Token.hasSeed true");
        } else {
            callback.invoke(false, "Heartbeat.Token.hasSeed false");
        }
    }

    @ReactMethod
    public void sendDocFaceAuthorization(ReadableMap parameters, Callback callback) {
        try {
            Intent intent = new Intent(this.reactContext, CaptureDocActivity.class);

            HashMap<String, Object> userData = parameters.toHashMap();
            if (parameters.hasKey("USER_PARAMS")) {
                userData = parameters.getMap("USER_PARAMS").toHashMap();
            }
            intent.putExtra("params", userData);

            if (parameters.hasKey("TEXT_CAPTIONS")) {
                HashMap<String, Object> instructions = parameters.getMap("TEXT_CAPTIONS").toHashMap();
                intent.putExtra("instructions", instructions);
            }

            this.reactContext.startActivityForResult(intent, SEND_DOC_FACE_AUTHORIZATION_REQUEST, null);
            this.callback = callback;
        } catch (Exception e) {
            callback.invoke("An error occurred requesting to Capture Document on Face Authorization");
        }
    }

    @ReactMethod
    public void startLivenessFaceAuthorization(ReadableMap parameters, Callback callback) {
        try {
            Intent intent = new Intent(this.reactContext, FaceSequenceActivity.class);

            HashMap<String, Object> userData = parameters.toHashMap();
            if (parameters.hasKey("USER_PARAMS")) {
                userData = parameters.getMap("USER_PARAMS").toHashMap();
            }
            intent.putExtra("params", userData);

            if (parameters.hasKey("TEXT_CAPTIONS")) {
                HashMap<String, Object> instructions = parameters.getMap("TEXT_CAPTIONS").toHashMap();
                intent.putExtra("instructions", instructions);
            }

            this.reactContext.startActivityForResult(intent, LIVENESS_FACE_AUTHORIATION_REQUEST, null);
            this.callback = callback;
        } catch (Exception e) {
            callback.invoke("An error occurred requesting to Start Liveness on Face Authorization");
        }
    }

    @ReactMethod
    public void startCameraOCR(ReadableMap parameters, Callback callback) {
        try {
            Intent intent = new Intent(this.reactContext, LivePreviewActivity.class);

            HashMap<String, Object> userData = parameters.toHashMap();
            if (parameters.hasKey("USER_PARAMS")) {
                userData = parameters.getMap("USER_PARAMS").toHashMap();
            }
            intent.putExtra("params", userData);

            if (parameters.hasKey("TEXT_CAPTIONS")) {
                HashMap<String, Object> instructions = parameters.getMap("TEXT_CAPTIONS").toHashMap();
                intent.putExtra("instructions", instructions);
            }

            this.reactContext.startActivityForResult(intent, LIVE_OCR_REQUEST, null);
            this.callback = callback;
        } catch (Exception e) {
            callback.invoke("An error occurred requesting to Start Camera on OCR");
        }
    }

    @ReactMethod
    public void sendFilesOCR(ReadableMap parameters, ReadableArray ocrFilesParameters, Callback callback) {
        try {
            Intent intent = new Intent(this.reactContext, FilesSenderActivity.class);
            String type = parameters.getString("TYPE") != null ? parameters.getString("TYPE") : "CNHD";

            HashMap<String, Object> userData = parameters.toHashMap();
            if (parameters.hasKey("USER_PARAMS")) {
                userData = parameters.getMap("USER_PARAMS").toHashMap();
                type = userData.get("TYPE") != null ? (String) userData.get("TYPE") : "CNHD";
            }
            intent.putExtra("params", userData);
            intent.putExtra("ID", type);

            if (parameters.hasKey("TEXT_CAPTIONS")) {
                HashMap<String, Object> instructions = parameters.getMap("TEXT_CAPTIONS").toHashMap();
                intent.putExtra("instructions", instructions);
            }

            ArrayList<Object> ocrFiles = ocrFilesParameters.toArrayList();
            intent.putExtra("FILES", ocrFiles);

            this.reactContext.startActivityForResult(intent, SEND_FILES_OCR_REQUEST, null);
            this.callback = callback;
        } catch (Exception e) {
            callback.invoke("An error occurred requesting to Send Files on OCR");
        }
    }

    private void process_send_doc_face_authorization_result(Intent data) {
        int statusCode = data.getExtras().getInt("FACERESULT");
        String image = "";
        if (data.hasExtra("FACEIMAGEID")) {
            String imageId = data.getStringExtra("FACEIMAGEID");
            Bitmap img = getBaseImage(imageId);
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            img.compress(Bitmap.CompressFormat.JPEG, 80, outputStream);
            image = Base64.encodeToString(outputStream.toByteArray(), Base64.NO_WRAP);
        }
        this.callback.invoke(statusCode, image);
    }

    private void process_liveness_face_authorization_result(Intent data) {
            int statusCode = data.getExtras().getInt("FACERESULT");
            WritableNativeArray images = new WritableNativeArray();
            if (data.hasExtra("FACEIMAGELISTID")) {
                String imageId = data.getStringExtra("FACEIMAGELISTID");
                List<byte[]> imageList = getImageList(imageId);
                for (byte[] image : imageList) {
                    images.pushString(Base64.encodeToString(image, Base64.NO_WRAP));
                }
            }
            this.callback.invoke(statusCode, images);
    }

    private void process_live_ocr_result(Intent data) {
        int statusCode = data.getExtras().getInt("OCRRESULTCODE");
        HashMap<String, String> ocrResult = new HashMap<>();
        String image = "";
        if (data.hasExtra("OCRRESULT")) {
            ocrResult = (HashMap<String, String>) data.getSerializableExtra("OCRRESULT");
        }
        if (data.hasExtra("OCRIMAGE")) {
            String imageId = data.getStringExtra("OCRIMAGE");
            byte[] img = getImage(imageId);
            if (img != null) {
                image = Base64.encodeToString(img, Base64.NO_WRAP);
            }
        }
        WritableNativeMap writableNativeMap = new WritableNativeMap();
        if (ocrResult != null) {
            for (String key : ocrResult.keySet()) {
                writableNativeMap.putString(key, ocrResult.get(key));
            }
        }
        this.callback.invoke(statusCode, writableNativeMap, image);
    }

    private void process_send_files_ocr_result(Intent data) {
        int statusCode = data.getExtras().getInt("OCRRESULTCODE");
        HashMap<String, String> ocrResult = new HashMap<>();
        WritableNativeMap writableNativeMap = new WritableNativeMap();
        if (data.hasExtra("OCRRESULT")) {
            ocrResult = (HashMap<String, String>) data.getSerializableExtra("OCRRESULT");
            if (ocrResult != null) {
                for (String key : ocrResult.keySet()) {
                    writableNativeMap.putString(key, ocrResult.get(key));
                }
            }
        }
        this.callback.invoke(statusCode, writableNativeMap);
    }

    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
        if (requestCode == SEND_DOC_FACE_AUTHORIZATION_REQUEST) {
            if (resultCode == 50548 && data != null) {
                process_send_doc_face_authorization_result(data);
            } else {
                callback.invoke(0);
            }
        } else if (requestCode == LIVENESS_FACE_AUTHORIATION_REQUEST) {
            if (resultCode == 50547 && data != null) {
                process_liveness_face_authorization_result(data);
            } else {
                callback.invoke(0);
            }
        } else if (requestCode == LIVE_OCR_REQUEST) {
            if (resultCode == 47897 && data != null) {
                process_live_ocr_result(data);
            } else {
                callback.invoke(0);
            }
        } else if (requestCode == SEND_FILES_OCR_REQUEST) {
            if (resultCode == 47897 && data != null) {
                process_send_files_ocr_result(data);
            } else {
                callback.invoke(0);
            }
        }
    }

    @Override
    public void onNewIntent(Intent intent) {
    }

    private List<byte[]> getImageList(String imageId) {
        try {
            Class<?> dataHolderClass = Class.forName("br.com.topaz.heartbeat.ofdcamera.ocr.DataHolder");
            Method method = dataHolderClass.getMethod("retrieve", String.class);

            return (List<byte[]>) method.invoke(null, imageId);
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    private Bitmap getBaseImage(String imageId) {
        try {
            Class<?> dataHolderClass = Class.forName("br.com.topaz.heartbeat.ofdcamera.ocr.DataHolder");
            Method method = dataHolderClass.getMethod("retrieve", String.class);

            return (Bitmap) method.invoke(null, imageId);
        } catch (Exception e) {
            e.printStackTrace();
            return Bitmap.createBitmap(100, 100, Bitmap.Config.RGB_565);
        }
    }

    private byte[] getImage(String imageId) {
        byte[] response = new byte[0];
        try {
            Class<?> dataHolderClass = Class.forName("br.com.topaz.heartbeat.ofdcamera.ocr.DataHolder");
            Method method = dataHolderClass.getMethod("retrieve", String.class);
            response = (byte[]) method.invoke(null, imageId);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return response;
    }

    private Token buildTokenObject(ReadableMap parameters) {
        Token token = new Token(this.reactContext);

        Map<String, Object> tokenParameters = parameters.toHashMap();
        for (String key : tokenParameters.keySet()) {
            token.addParameter(key, tokenParameters.get(key).toString());
        }

        return token;
    }
}
