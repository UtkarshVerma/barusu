#ifndef _EGL_H
#define _EGL_H

#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <stdbool.h>
#include <wayland-client.h>

extern EGLDisplay egl_display;
extern EGLConfig egl_config;
extern EGLContext egl_context;

extern PFNEGLCREATEPLATFORMWINDOWSURFACEEXTPROC
    eglCreatePlatformWindowSurfaceEXT;

bool egl_init(struct wl_display *display);

void egl_finish(void);
#endif
