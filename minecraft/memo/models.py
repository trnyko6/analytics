from django.db import models

# Create your models here.
class MinecraftMemo(models.Model):
    title = models.CharField(max_length=150)
    text = models.TextField(blank=True)
    coordinate_x = models.IntegerField()
    coordinate_y = models.IntegerField()
    coordinate_z = models.IntegerField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):

        return self.title