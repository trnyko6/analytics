from django.forms import ModelForm
from .models import MinecraftMemo

class MinecraftMemoForm(ModelForm):

    class Meta:
        model = MinecraftMemo
        fields = ["title", "text", "coordinate_x", "coordinate_y", "coordinate_z"]
        