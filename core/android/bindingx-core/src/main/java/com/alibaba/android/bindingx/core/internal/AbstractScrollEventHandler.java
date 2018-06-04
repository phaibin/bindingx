/**
 * Copyright 2018 Alibaba Group
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.alibaba.android.bindingx.core.internal;

import android.content.Context;
import android.support.annotation.CallSuper;
import android.support.annotation.NonNull;

import com.alibaba.android.bindingx.core.BindingXEventType;
import com.alibaba.android.bindingx.core.LogProxy;
import com.alibaba.android.bindingx.core.PlatformManager;

import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

/**
 * Description:
 *
 * An abstract scroll event handler. Because there are some difference between Weex and ReactNative.
 * In Weex, both Scroller and List are scrollable. However in ReactNative, only ScrollView is scrollable.
 *
 * Created by rowandjj(chuyi)<br/>
 */

public abstract class AbstractScrollEventHandler extends AbstractEventHandler {

    protected int mContentOffsetX, mContentOffsetY;
    private boolean isStart = false;

    public AbstractScrollEventHandler(Context context, PlatformManager manager, Object... extension) {
        super(context, manager, extension);
    }

    @Override
    @CallSuper
    public boolean onDisable(@NonNull String sourceRef, @NonNull String eventType) {
        clearExpressions();
        isStart = false;
        fireEventByState(BindingXConstants.STATE_END, mContentOffsetX, mContentOffsetY,0,0,0,0);
        return true;
    }

    @Override
    protected void onExit(@NonNull Map<String, Object> scope) {
        float contentOffsetX = (float) scope.get("internal_x");
        float contentOffsetY = (float) scope.get("internal_y");
        this.fireEventByState(BindingXConstants.STATE_EXIT, contentOffsetX, contentOffsetY,0,0,0,0);
    }

    @Override
    @CallSuper
    public void onDestroy() {
        super.onDestroy();
        isStart = false;
    }

    /**
     * @param contentOffsetX the absolute horizontal offset in pixel
     * @param contentOffsetY the absolute vertical offset in pixel
     * @param dx The amount of horizontal scroll relative to last onscroll event
     * @param dy The amount of vertical scroll offset relative to last onscroll event
     * @param tdx The amount of horizontal scroll offset relative to last inflection point
     * @param tdy The amount of vertical scroll offset relative to last inflection point
     * */
    protected void handleScrollEvent(int contentOffsetX, int contentOffsetY, int dx, int dy,
                                   int tdx, int tdy) {
        if(LogProxy.sEnableLog) {
            LogProxy.d(String.format(Locale.getDefault(),
                    "[ScrollHandler] scroll changed. (contentOffsetX:%d,contentOffsetY:%d,dx:%d,dy:%d,tdx:%d,tdy:%d)",
                    contentOffsetX,contentOffsetY,dx,dy,tdx,tdy));
        }

        this.mContentOffsetX = contentOffsetX;
        this.mContentOffsetY = contentOffsetY;

        if(!isStart) {
            isStart = true;
            fireEventByState(BindingXConstants.STATE_START,contentOffsetX,contentOffsetY,dx,dy,tdx,tdy);
        }

        try {
            JSMath.applyScrollValuesToScope(mScope, contentOffsetX, contentOffsetY, dx, dy, tdx, tdy, mPlatformManager.getResolutionTranslator());
            if(!evaluateExitExpression(mExitExpressionPair,mScope)) {
                consumeExpression(mExpressionHoldersMap, mScope, BindingXEventType.TYPE_SCROLL);
            }
        } catch (Exception e) {
            LogProxy.e("runtime error", e);
        }
    }

    protected void fireEventByState(@BindingXConstants.State String state, float contentOffsetX, float contentOffsetY,
                                    float dx, float dy, float tdx, float tdy) {
        if (mCallback != null) {
            Map<String, Object> param = new HashMap<>();
            param.put("state", state);
            double x = mPlatformManager.getResolutionTranslator().nativeToWeb(contentOffsetX);
            double y = mPlatformManager.getResolutionTranslator().nativeToWeb(contentOffsetY);
            param.put("x", x);
            param.put("y", y);

            double _dx = mPlatformManager.getResolutionTranslator().nativeToWeb(dx);
            double _dy = mPlatformManager.getResolutionTranslator().nativeToWeb(dy);
            param.put("dx", _dx);
            param.put("dy", _dy);

            double _tdx = mPlatformManager.getResolutionTranslator().nativeToWeb(tdx);
            double _tdy = mPlatformManager.getResolutionTranslator().nativeToWeb(tdy);
            param.put("tdx", _tdx);
            param.put("tdy", _tdy);
            param.put(BindingXConstants.KEY_TOKEN, mToken);

            mCallback.callback(param);
            LogProxy.d(">>>>>>>>>>>fire event:(" + state + "," + x + "," + y + ","+ _dx  +","+ _dy +"," + _tdx +"," + _tdy +")");
        }
    }

}
