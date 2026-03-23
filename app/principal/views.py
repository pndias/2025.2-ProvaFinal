from django.http import HttpResponse


def home(request):
    return HttpResponse("alô professor, sou Pablo Dias da turma SO 2025.2")
