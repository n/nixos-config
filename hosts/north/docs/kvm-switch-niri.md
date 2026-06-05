# KVM switch causes black screen with Niri

## Problem

When switching away from this machine on the KVM and switching back, the display
stays dark. The system is still running and accessible via SSH. This only affects
Niri; Sway handles KVM switches correctly.

## Root cause

The display is a 3440x1440@60Hz ultrawide connected via DisplayPort. The DRM
`max bpc` property defaults to 16 on this AMD GPU (Radeon RX 7900 XT, Navi 31).

At 16 bpc, the DisplayPort link requires about 14.3 Gbps. At 8 bpc, it requires
about 7.1 Gbps. When the KVM switches back, DisplayPort must renegotiate the link
with link training. The KVM degrades signal integrity enough that link training
fails at 16 bpc bandwidth but succeeds at 8 bpc.

Sway (wlroots) hardcodes `max_bpc=8` on all connectors. Niri used to do the same
but removed this in v25.11, leaving the kernel/driver default of 16. This is why
the problem appeared after switching to Niri.

## Evidence

Collected via `scripts/drm-state-dump.sh` (deleted):

- Fresh boot with Niri only: `max bpc = 16`; KVM switch -> black screen every time
- After Sway ran: `max bpc = 8`; KVM switch -> works every time
- Manually setting `max_bpc=8` via DRM ioctl: KVM switch -> works every time
- Setting back to `max_bpc=16`: KVM switch -> black screen returns
- VT switch (`chvt 3 && sleep 1 && chvt 2`) recovers the display once, but the
  next KVM switch goes dark again. It forces a DRM master release/reacquire cycle
  which does a full modeset, but does not change `max_bpc`.

## Fix

The Niri config sets `max-bpc 8` directly on the external display output:

```kdl
output "LG Electronics LG HDR WQHD 0x0006E08B" {
    max-bpc 8
}
```

This keeps DisplayPort bandwidth low enough for reliable KVM link retraining
without a pre-display-manager systemd service or raw DRM ioctl script.

## Relevant Niri issues

- [#3410](https://github.com/YaLTeR/niri/issues/3410) - EDID race condition on connector reconnect
- [#2560](https://github.com/YaLTeR/niri/issues/2560) - Niri doesn't handle EDID changes at runtime
- [#2907](https://github.com/YaLTeR/niri/issues/2907) - Display stays black after monitor power cycle
- [#3719](https://github.com/YaLTeR/niri/issues/3719) - Monitor freeze after off/on (AMD, NixOS)
