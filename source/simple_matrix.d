module simple_matrix;

import core.stdc.stdlib;


struct Vector(T)
{
	T* ptr;
	size_t length;
	ptrdiff_t shift;

	typeof(this) save() @property
	{
		return this;
	}

	size_t opDollar(size_t pos : 1)()
	{
		return length;
	}

	auto ref front() @property
	in{
		assert(length);
	}
	body{
		return ptr[0];
	}

	void popFront()
	in{
		assert(length);
	}
	body{
		 ptr += shift;
		 length--;
	}

	bool empty() const @property
	{
		return length == 0;
	}

	auto ref opIndex(size_t index)
	in {
		assert(index < length);
	}
	body {
		return ptr[shift*index];
	}
}


struct Matrix(T)
{
	T* ptr;
	size_t height;
	size_t width;	
	ptrdiff_t shift;

	Vector!T column(size_t index)
	in
	{
		assert(index < width);
	}
	body
	{
		return Vector!T(ptr+index, height, shift);
	}


	Transposed!T transposed()
	{
		return Transposed!T(this);
	}


	this(size_t height, size_t width)
	{
		this(height, width, width);
	}


	this(T* ptr, size_t height, size_t width)
	{
		this(ptr, height, width, width);
	}


	this(size_t height, size_t width, size_t shift)
	{
		this(new T[height * shift].ptr, height, width, shift);
	}


	this(T* ptr, size_t height, size_t width, size_t shift)
	{
		this.ptr = ptr;
		this.height = height;
		this.width = width;
		this.shift = shift;
	}


	const(T)* end() const
	{
		return ptr+height*shift;
	}


	T[] opIndex(size_t heightI)
	in {
		assert(heightI < height);
	}
	body {
		auto l = heightI * shift;
		return ptr[l .. l + width];
	}


	auto ref opIndex(size_t heightI, size_t widthI)
	in {
		assert(heightI < height);
		assert(widthI < width);		
	}
	body {
		return ptr[heightI * shift + widthI];
	}


	T[] array()
	{
		return ptr[0..height * width];
	}


	T[] front()
	{
		assert(height);
		return ptr[0..width];
	}


	void popFront()
	in{ assert(height); }
	body {
		ptr += shift;
		height--;
	}


	void popFrontN(size_t n)
	in{ assert(height >= n); }
	body {
		ptr += shift*n;
		height -= n;
	}


	bool empty() const 
	{
		return length == 0;
	}


	size_t length() const 
	{
		return height;
	}


	T[][] arrays() 
	{
		auto r = new T[][height];
		foreach(i, ref e; r)
		{
			const l = i * width;
			e = ptr[l..l+width];
		}
		return r;
	}


	auto transpose() const
	{
		import std.traits : Unqual;
		auto m = Matrix!(Unqual!T)(width, height);
		size_t i;
		foreach(row; this)
		{
			foreach(j, e; row)
			{
				m[j, i] = e;
			}
			i++;
		}
		
		return m;
	}

	T* ptrEnd()
	{
		return ptr+height*shift;
	}
}


struct Transposed(T)
{
	Matrix!T matrix;

	size_t width() const @property
	{
		return matrix.height;
	}

	size_t height() const @property
	{
		return matrix.width;
	}
	
	Matrix!T transposed()  
	{
		return matrix;
	}
	
	T[] column(size_t index)
	{
		return matrix[index];
	}
	
	Vector!T opIndex(size_t index) 
	{
		return matrix.column(index);
	}

	auto ref opIndex(size_t index1, size_t index2)
	{
		return matrix[index2, index1];
	}

	Vector!T front()
	{
		assert(!empty);
		return matrix.column(0);
	}

	bool empty() const 
	{
		return length == 0;
	}

	void popFront()
	in{ assert(matrix.width); }
	body {
		matrix.ptr++;
		matrix.width--;
	}


	void popFrontN(size_t n)
	in{ assert(matrix.width >= n); }
	body {
		matrix.ptr += n;
		matrix.width -= n;
	}


	size_t length() const 
	{
		return matrix.width;
	}
}


unittest {
	alias M = Matrix!double;
	alias T = Transposed!double;
	alias V = Vector!double;
}
