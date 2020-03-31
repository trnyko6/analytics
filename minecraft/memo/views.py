from django.shortcuts import render, redirect

# Create your views here.
from .models import MinecraftMemo
from .forms import MinecraftMemoForm
from django.shortcuts import get_object_or_404
from django.views.decorators.http import require_POST

def index(request):
    memos = MinecraftMemo.objects.all().order_by('-updated_at')
    return render(request, 'memo/index.html', { 'memos': memos })

def detail(request, memo_id):

    memo = get_object_or_404(MinecraftMemo, id=memo_id)
    return render(request, 'memo/detail.html', {'memo': memo})

def new_memo(request):

    if request.method == "POST":
        form = MinecraftMemoForm(request.POST)

        if form.is_valid():
            form.save()
            return redirect('memo:index')
    else:   
        form = MinecraftMemoForm
    return render(request, 'memo/new_memo.html', {'form': form })

@require_POST
def delete_memo(request, memo_id):

    memo = get_object_or_404(MinecraftMemo, id=memo_id)
    memo.delete()
    return redirect('memo:index')

def edit_memo(request, memo_id):
    memo = get_object_or_404(MinecraftMemo, id=memo_id)
    if request.method == "POST":
        form = MinecraftMemoForm(request.POST, instance=memo)
        if form.is_valid():
            form.save()
            return redirect('memo:index')
    else:
        form = MinecraftMemoForm(instance=memo)
    return render(request, 'memo/edit_memo.html', {'form': form, 'memo':memo })