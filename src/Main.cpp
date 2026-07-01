# include <Siv3D.hpp>

void Main()
{
    Scene::SetBackground(ColorF{ 0.18, 0.20, 0.24 });

    const Font font{ 28 };

    while (System::Update())
    {
        font(U"Siv3D template").draw(40, 40, Palette::White);
        font(U"Edit src/Main.cpp and rebuild").draw(40, 84, Palette::Skyblue);
    }
}
