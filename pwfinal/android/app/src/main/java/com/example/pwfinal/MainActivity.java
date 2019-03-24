package com.example.pwfinal;

import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.util.Log;
import android.widget.Toast;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.ml.common.FirebaseMLException;
import com.google.firebase.ml.common.modeldownload.FirebaseCloudModelSource;
import com.google.firebase.ml.common.modeldownload.FirebaseLocalModelSource;
import com.google.firebase.ml.common.modeldownload.FirebaseModelDownloadConditions;
import com.google.firebase.ml.common.modeldownload.FirebaseModelManager;
import com.google.firebase.ml.custom.FirebaseModelDataType;
import com.google.firebase.ml.custom.FirebaseModelInputOutputOptions;
import com.google.firebase.ml.custom.FirebaseModelInputs;
import com.google.firebase.ml.custom.FirebaseModelInterpreter;
import com.google.firebase.ml.custom.FirebaseModelOptions;
import com.google.firebase.ml.custom.FirebaseModelOutputs;

import java.util.ArrayList;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "plawiz";
  float[] probabilities;
  private FirebaseModelOptions options;

  @Override
  protected void onStart() {
    super.onStart();
    FirebaseModelDownloadConditions.Builder conditionsBuilder = new FirebaseModelDownloadConditions.Builder();
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N)
      conditionsBuilder = conditionsBuilder.requireCharging().requireDeviceIdle();
    FirebaseModelDownloadConditions conditions = conditionsBuilder.build();
    FirebaseCloudModelSource cloudSource = new FirebaseCloudModelSource.Builder(CHANNEL)
            .enableModelUpdates(true)
            .setInitialDownloadConditions(conditions)
            .setUpdatesDownloadConditions(conditions)
            .build();
    FirebaseModelManager.getInstance().registerCloudModelSource(cloudSource);
    FirebaseLocalModelSource localSource = new FirebaseLocalModelSource.Builder(CHANNEL)
            .setAssetFilePath("pw.tflite")
            .build();
    FirebaseModelManager.getInstance().registerLocalModelSource(localSource);
    options = new FirebaseModelOptions.Builder()
            .setCloudModelName(CHANNEL)
            .setLocalModelName(CHANNEL)
            .build();
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
            new MethodChannel.MethodCallHandler() {
              @Override
              public void onMethodCall(final MethodCall methodCall, final MethodChannel.Result result) {
                switch (methodCall.method) {
                  case "runModel":
                    float[] temp = new float[27];
                    ArrayList<Double> list = methodCall.argument("arr");
                    assert list != null;
                    Log.i("DK - Passed ARG", list.toString());
                    for (int i = 0; i < list.size(); i++)
                      temp[i] = list.get(i).floatValue();
                    float[][] arr = new float[][]{temp};
                    try {
                      FirebaseModelInterpreter firebaseInterpreter = FirebaseModelInterpreter.getInstance(options);
                      FirebaseModelInputOutputOptions inputOutputOptions = new FirebaseModelInputOutputOptions.Builder()
                              .setInputFormat(0, FirebaseModelDataType.FLOAT32, new int[]{1, 27})
                              .setOutputFormat(0, FirebaseModelDataType.FLOAT32, new int[]{1, 28})
                              .build();
                      FirebaseModelInputs inputs = new FirebaseModelInputs.Builder()
                              .add(arr)
                              .build();
                      assert firebaseInterpreter != null;
                      firebaseInterpreter.run(inputs, inputOutputOptions)
                              .addOnSuccessListener(new OnSuccessListener<FirebaseModelOutputs>() {
                                @Override
                                public void onSuccess(FirebaseModelOutputs firebaseModelOutputs) {
                                  float[][] modelResult = firebaseModelOutputs.getOutput(0);
                                  probabilities = modelResult[0];
                                  if (probabilities != null) {
                                    ArrayList<Double> res = new ArrayList<>();
                                    for (Float i : probabilities)
                                      res.add(i.doubleValue());
                                    result.success(res);
                                  } else
                                    result.error("Model Error", "Model results are null!", null);
                                }
                              })
                              .addOnFailureListener(new OnFailureListener() {
                                @Override
                                public void onFailure(@NonNull Exception e) {
                                  Log.e("DKexception", e.getMessage());
                                  probabilities = null;
                                }
                              });
                    } catch (FirebaseMLException e) {
                      e.printStackTrace();
                    }
                    break;
                  case "showToast":
                    String msg = methodCall.argument("msg").toString();
                    Toast.makeText(MainActivity.this, msg, Toast.LENGTH_LONG).show();
                    result.success(true);
                    break;
                  default:
                    result.notImplemented();
                    break;
                }
              }
            }
    );
  }
}
