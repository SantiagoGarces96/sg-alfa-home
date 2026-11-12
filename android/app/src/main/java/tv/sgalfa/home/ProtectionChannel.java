/*
 * SG Alfa Home — puente entre Flutter (pantalla «Protección SG Alfa») y lo nativo.
 */
package tv.sgalfa.home;

import android.app.Activity;
import android.content.Intent;
import android.net.VpnService;
import android.provider.Settings;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;

public final class ProtectionChannel {

    public static final String CHANNEL = "tv.sgalfa.home/protection";
    private static final int REQ_VPN = 4711;

    private final Activity activity;
    private MethodChannel.Result pendingVpn;

    public ProtectionChannel(Activity activity) {
        this.activity = activity;
    }

    public void register(BinaryMessenger messenger) {
        new MethodChannel(messenger, CHANNEL).setMethodCallHandler((call, result) -> {
            try {
                switch (call.method) {
                    case "getState":
                        result.success(state());
                        break;
                    case "setAdblock":
                        setAdblock(Boolean.TRUE.equals(call.arguments), result);
                        break;
                    case "openAccessibilitySettings":
                        activity.startActivity(new Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK));
                        result.success(true);
                        break;
                    case "setMacroEnabled": {
                        String id = call.argument("id");
                        Boolean on = call.argument("enabled");
                        setMacroEnabled(id, Boolean.TRUE.equals(on));
                        result.success(state());
                        break;
                    }
                    default:
                        result.notImplemented();
                }
            } catch (Exception e) {
                result.error("sgalfa", e.getMessage(), null);
            }
        });
    }

    /** Al abrir el launcher (p. ej. tras reiniciar la tele) vuelve a encender el bloqueo si estaba puesto. */
    public static void resumeIfWanted(Activity a) {
        if (DnsBlockVpnService.isWanted(a) && !DnsBlockVpnService.isRunning() && VpnService.prepare(a) == null) {
            a.startService(new Intent(a, DnsBlockVpnService.class).setAction(DnsBlockVpnService.ACTION_START));
        }
    }

    private Map<String, Object> state() {
        Map<String, Object> m = new HashMap<>();
        m.put("adblock", DnsBlockVpnService.isRunning());
        m.put("automation", AutoClickService.isEnabled(activity));
        List<Map<String, Object>> list = new ArrayList<>();
        for (Macros.Macro macro : AutoClickService.load(activity)) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", macro.id);
            item.put("name", macro.name);
            item.put("enabled", macro.enabled);
            item.put("description", Macros.describe(macro));
            list.add(item);
        }
        m.put("macros", list);
        return m;
    }

    private void setMacroEnabled(String id, boolean on) {
        List<Macros.Macro> list = new ArrayList<>(AutoClickService.load(activity));
        for (int i = 0; i < list.size(); i++) {
            if (list.get(i).id.equals(id)) list.set(i, list.get(i).withEnabled(on));
        }
        AutoClickService.save(activity, list);
    }

    private void setAdblock(boolean on, MethodChannel.Result result) {
        if (!on) {
            activity.startService(new Intent(activity, DnsBlockVpnService.class).setAction(DnsBlockVpnService.ACTION_STOP));
            result.success(false);
            return;
        }
        Intent prepare = VpnService.prepare(activity);
        if (prepare == null) {
            startVpn();
            result.success(true);
        } else {
            // La tele pide permiso una vez («¿Permitir conexión VPN?»).
            pendingVpn = result;
            activity.startActivityForResult(prepare, REQ_VPN);
        }
    }

    private void startVpn() {
        activity.startService(new Intent(activity, DnsBlockVpnService.class).setAction(DnsBlockVpnService.ACTION_START));
    }

    /** Llamar desde MainActivity.onActivityResult. Devuelve true si era nuestro. */
    public boolean onActivityResult(int requestCode, int resultCode) {
        if (requestCode != REQ_VPN) return false;
        boolean ok = resultCode == Activity.RESULT_OK;
        if (ok) startVpn();
        if (pendingVpn != null) {
            pendingVpn.success(ok);
            pendingVpn = null;
        }
        return true;
    }
}
