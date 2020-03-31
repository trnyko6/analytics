from django.contrib import admin

# Register your models here.
from .models import MinecraftMemo

class MemoAdmin(admin.ModelAdmin):
    list_display = ("id", "title", "text", "coordinate_x", "coordinate_y", "coordinate_z", "created_at", "updated_at")
    list_display_links = ('id', 'title')

admin.site.register(MinecraftMemo, MemoAdmin)